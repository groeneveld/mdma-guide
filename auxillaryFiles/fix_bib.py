#!/usr/bin/env python3
"""Check and proof-read references.bib.

Runs eight steps in serial:

  1. Broken file links -- print the key of every entry whose `file` field
     points at a path that doesn't exist on disk. Fast, no model needed; runs
     first so problems surface before the long model pass.

  2. Layout cleanup -- reformat the whole file with `biber --tool` (consistent
     indentation, aligned `=`, one field per line, trailing commas) and drop
     the JabRef @comment metadata. This is biblatex-native, so unlike bibcop it
     handles @online/date/journaltitle etc. biber --tool is deterministic and
     trusted, so its output replaces the file without further verification.
     Runs before proof-reading so the model pass operates on the cleaned-up
     file. Skip with --no-format.

  3. Data-model validation -- re-run the file through `biber --tool
     --validate-datamodel` and report the warnings from biber's .blg log
     (missing required fields, unknown fields, malformed dates). Uses the SAME
     biblatex-aware tool as step 2, so it understands every entry type in the
     file (@online, @unpublished, @report, ...) -- unlike BibTeX-only linters,
     which can't even parse a quarter of this bibliography. Read-only: the
     reformatted output is discarded, only the log is read. Skip with
     --no-validate.

  4. Entry sanity checks -- offline, report-only diagnostics over every entry:
     duplicate citation keys, near-duplicate titles (the same paper cited twice
     under two keys), page ranges with a single hyphen or reversed bounds, and
     non-integer year / malformed date values. Deterministic, no network, no
     edits -- each finding is flagged for a human to resolve.

  5. PubPeer comments -- batch every `doi` to PubPeer's public v3 endpoint (the
     one the browser extension uses, so no API key) and report each cited paper
     that has post-publication comments, with the comment count and a link to
     the thread. Those comments often flag a retraction, data problem, or
     correction worth knowing before citing. Read-only and report-only;
     network-bound. Skip with --no-pubpeer.

  6. Live links -- probe every `url` and `doi` over the network and report the
     ones that aren't clearly reachable, bucketed into dead (definitely gone),
     needs-review (blocked / timed out / server error -- ambiguous), and live.
     DOIs are validated through doi.org WITHOUT following the redirect: a 3xx
     means the DOI is registered (so the link is good), a 404 means it isn't.
     This sidesteps publisher bot-blocking, which says nothing about whether the
     DOI resolves. Read-only and report-only; network-bound, so it runs
     concurrently. Skip with --no-links.

  7. Preprint -> published (Crossref) -- for every unpublished/preprint-type
     entry (@unpublished, @online, @misc) that carries a `doi`, ask Crossref
     whether that preprint now has a version of record. Crossref records the
     published version under the work's relation.is-preprint-of, so an entry
     that comes back with one is a preprint you cited that has since appeared in
     a journal and can be updated to the published DOI. Read-only and
     report-only; network-bound, so DOIs are queried concurrently. Crossref's
     polite pool is used (requests identify with a mailto). Skip with
     --no-crossref.

  8. Title proof-reading (see below).

For every entry, the title-like fields

    title, booktitle, eventtitle, journaltitle

are corrected in two layered steps, both deterministic (no model, no network):

  a. Brace protection (on the ORIGINAL casing, where an acronym is still
     distinguishable from a like-spelled ordinary word): every proper noun,
     acronym, and initialism that must stay capitalized in lowercase prose is
     wrapped in curly braces so the bibliography style can't lowercase it
     (e.g. MDMA -> {MDMA}, stanford -> {Stanford}). Two rules drive it -- an
     acronym auto-rule (a token with >=2 uppercase letters whose lowercase form
     is not an ordinary English word) and a curated word list (capit_words.txt,
     which pins canonical casing and covers proper nouns the auto-rule misses).
     A lowercase ordinary word is never promoted (the pronoun "us" stays "us").
  b. Title-casing (folded in from title_case.py): the brace-protected value is
     run through `titlecase`, which preserves the {braced} groups from step a.
     If the result has unbalanced braces it is rejected and the entry untouched.

  (NB: unlike the former local-LLM pass, this no longer repairs spelling or
  mis-rendered ligatures -- it only fixes capitalization/bracing and case.)

Nothing leaves the machine. The .bib is edited by targeted, balanced-brace
replacement (not full re-serialization), so the diff is limited to the field
values that actually changed, and the file is atomically rewritten after every
single correction -- a crash mid-run leaves a valid file with all prior fixes
intact. Every change is appended to bib_fixes.txt.

Usage:
    python3 fix_bib.py [--dry-run] [--limit N] [--no-format] [--no-validate]
                       [--no-pubpeer] [--no-links] [--no-crossref]

Run from the repo root or auxillaryFiles/; paths resolve relative to the script.
"""
import os
import re
import sys
import shutil
import pathlib
import tempfile
import subprocess
from collections import Counter

try:
    from titlecase import titlecase
except Exception:           # package absent -> title-casing layer disabled
    titlecase = None

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent
BIB = REPO / "references.bib"
LOG = HERE / "bib_fixes.txt"

DRY_RUN = "--dry-run" in sys.argv
NO_FORMAT = "--no-format" in sys.argv     # skip the biber layout pass
NO_VALIDATE = "--no-validate" in sys.argv # skip the biber data-model validation
NO_PUBPEER = "--no-pubpeer" in sys.argv   # skip the PubPeer comment check
NO_LINKS = "--no-links" in sys.argv       # skip the URL/DOI liveness check
NO_CROSSREF = "--no-crossref" in sys.argv # skip the Crossref preprint check
LIMIT = None
if "--limit" in sys.argv:
    LIMIT = int(sys.argv[sys.argv.index("--limit") + 1])

# Fields whose contents are human-readable titles worth proof-reading.
FIELDS = ["title", "booktitle", "eventtitle", "journaltitle"]

# Deterministic capitalization protection (replaces the old local-LLM pass).
# The value's title-like fields are brace-protected so a sentence-casing bib
# style can't lowercase a term that must stay capitalized. Two layers, both
# offline and reproducible -- no model, no network:
#
#   1. Acronym auto-rule: a token carrying >=2 uppercase letters whose lowercase
#      form is NOT an ordinary English word is braced as-is (MDMA, CYP2D6,
#      ICD-11, BetterHelp). Excluding common words keeps all-caps emphasis
#      ("RETRACTED ARTICLE") and shouted ordinary words from being protected.
#   2. Word list: every term in capit_words.txt is braced using its canonical
#      casing (mdma -> {MDMA}, stanford -> {Stanford}), with a guard so an
#      all-lowercase common word is never promoted (the pronoun "us" stays "us"
#      while "US"/"USA" become "{US}"/"{USA}"). This pins mixed-case acronyms
#      (CBTp) and covers proper nouns the acronym rule can't see.
#
# Bracing runs on the ORIGINAL casing -- where "GRADE" (acronym) is still
# distinguishable from "grade" (word) -- and the result is title-cased
# afterwards (title-casing preserves {braced} groups).
WORDLIST = HERE / "capit_words.txt"


def load_terms():
    """Curated terms from capit_words.txt (one per line; blank / '#' ignored).
    Returns [] if the file is absent, leaving the acronym rule to run alone."""
    if not WORDLIST.is_file():
        return []
    out = []
    for line in WORDLIST.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            out.append(line)
    return out


def load_common_words():
    """Lowercased system word list, used so an all-lowercase ordinary word is
    never promoted to an acronym. Empty set when no list is installed -> the
    guard simply never fires (the curated list still applies)."""
    for p in ("/usr/share/dict/words", "/usr/dict/words"):
        try:
            with open(p, encoding="utf-8", errors="ignore") as fh:
                return {w.strip().lower() for w in fh if w.strip()}
        except OSError:
            continue
    return set()


TERMS = load_terms()
COMMON_WORDS = load_common_words()


def _build_term_re(terms, flags):
    """Compile one alternation that matches any of `terms`. Longest first so a
    phrase ("New Zealand") wins over its prefix ("New"). Boundaries exclude
    letters/digits (so "US" won't fire inside a word) and braces/backslash (so
    already-braced or \\command text is left alone). None if `terms` is empty."""
    if not terms:
        return None
    alt = "|".join(re.escape(t) for t in sorted(terms, key=len, reverse=True))
    return re.compile(r"(?<![A-Za-z0-9{\\])(?:" + alt + r")(?![A-Za-z0-9}])",
                      flags)


# A term whose lowercase form is also an ordinary English word (US, ACT, GRADE)
# is matched CASE-SENSITIVELY -- only the literal acronym casing is braced, so
# the Title-Case word "Act" is never turned into "{ACT}". Every other term is
# matched case-insensitively, which also repairs wrong casing (mdma -> {MDMA}).
_TERMS_CI = [t for t in TERMS if t.lower() not in COMMON_WORDS]
_TERMS_CS = [t for t in TERMS if t.lower() in COMMON_WORDS]
TERM_CANON = {t.lower(): t for t in _TERMS_CI}     # lowered -> canonical casing
TERM_RE_CI = _build_term_re(_TERMS_CI, re.IGNORECASE)
TERM_RE_CS = _build_term_re(_TERMS_CS, 0)

# A whitespace-free token: letters/digits, optionally hyphen-joined (MDMA,
# ICD-11, 5-HT, CYP2D6, CBTp). Same brace/backslash-aware boundaries.
TOKEN_RE = re.compile(
    r"(?<![A-Za-z0-9{\\])([A-Za-z0-9]+(?:-[A-Za-z0-9]+)*)(?![A-Za-z0-9}])")
# Two-or-more CONSECUTIVE uppercase letters -- the signature of an acronym
# (MDMA, CBTp, ICD-11), which a title-cased hyphen compound ("Meta-Analysis")
# never has. camelCase brands (BetterHelp) lack this and rely on the word list.
_CONSEC_UPPER = re.compile(r"[A-Z]{2}")


# --- deterministic capitalization protection --------------------------------
def _is_acronym(token: str) -> bool:
    """True if `token` should be auto-braced as an acronym. It must carry a run
    of >=2 consecutive uppercase letters -- the signature of an acronym (MDMA,
    CYP2D6, ICD-11), which a title-cased hyphen compound ("Meta-Analysis") never
    has. A fully-uppercase token is then ALWAYS braced: title-casing silently
    lowercases an unprotected all-caps word (JAMA -> Jama), so leaving it
    unbraced would corrupt it. A mixed-case token (CBTp) is braced only when its
    lowercase form is not an ordinary word, which keeps shouted words out."""
    if not _CONSEC_UPPER.search(token):
        return False
    if token.isupper():                    # all-caps: must survive title-casing
        return True
    return token.lower() not in COMMON_WORDS


def _protect_segment(seg: str) -> str:
    """Brace-protect one run of text that is NOT already inside a {group}.
    Curated terms run first so a multi-chunk curated token (5-HT, ICD-11,
    MDMA-HCl) is braced whole with canonical casing. The acronym pass then
    handles everything else, judging each hyphen-separated chunk on its own so
    MDMA-Assisted becomes {MDMA}-Assisted, not {MDMA-Assisted}. Both passes are
    blocked from re-entering a just-added brace by their regex boundaries."""
    if TERM_RE_CI is not None:
        seg = TERM_RE_CI.sub(
            lambda m: "{" + TERM_CANON[m.group(0).lower()] + "}", seg)
    if TERM_RE_CS is not None:                 # exact casing already canonical
        seg = TERM_RE_CS.sub(lambda m: "{" + m.group(0) + "}", seg)

    def acro(m):
        return "-".join("{" + p + "}" if _is_acronym(p) else p
                        for p in m.group(1).split("-"))
    return TOKEN_RE.sub(acro, seg)


def brace_protect(value: str) -> str:
    """Brace-protect a field value, leaving any pre-existing {braced} groups
    (and \\command{...} units) untouched -- only the text between top-level
    braces is transformed. Operates on the ORIGINAL casing so acronyms are still
    distinguishable from like-spelled ordinary words."""
    out = []
    i, n = 0, len(value)
    while i < n:
        j = value.find("{", i)
        if j < 0:                                   # no more braces: tail is open
            out.append(_protect_segment(value[i:]))
            break
        if j > i:                                   # open text before the brace
            out.append(_protect_segment(value[i:j]))
        close = _match_brace(value, j)
        if close < 0:                               # unbalanced: leave remainder
            out.append(value[i:])
            i = n
            break
        out.append(value[j:close + 1])              # existing group, verbatim
        i = close + 1
    return "".join(out)


def protect_caps(value: str):
    """Brace-protect then title-case a field value (title-casing preserves the
    braces). Returns (new, None) when it differs from `value`, else
    (None, 'unchanged'); also (None, 'unbalanced-braces') as a safety net so a
    malformed result can never overwrite the entry."""
    staged = titlecase_value(brace_protect(value))
    if staged.count("{") != staged.count("}"):
        return None, "unbalanced-braces"
    if staged == value:
        return None, "unchanged"
    return staged, None


# --- balanced-brace .bib field extraction -----------------------------------
def _match_brace(raw: str, open_idx: int) -> int:
    """Index of the `}` matching the `{` at open_idx, or -1."""
    depth = 0
    for i in range(open_idx, len(raw)):
        c = raw[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
    return -1


def get_field(raw: str, key: str, field: str):
    """Locate `field` inside the entry `key`. Returns (value, start, end) where
    value is the text between the delimiters and [start, end) is its span in
    `raw`, or None if absent. Handles {braced} and "quoted" values and nested
    braces. Re-derived from the live `raw` every call, so it stays correct after
    earlier edits shifted offsets."""
    hm = re.search(r"@\w+\s*(\{)\s*" + re.escape(key) + r"\s*,", raw)
    if not hm:
        return None
    entry_close = _match_brace(raw, hm.start(1))
    if entry_close == -1:
        return None
    # A field starts after a delimiter ( { or , or newline ) inside the entry.
    fpat = re.compile(r"[\n,{]\s*" + re.escape(field) + r"\s*=\s*",
                      re.IGNORECASE)
    fm = fpat.search(raw, hm.end(), entry_close)
    if not fm:
        return None
    i = fm.end()
    if i >= len(raw):
        return None
    if raw[i] == "{":
        close = _match_brace(raw, i)
        if close == -1 or close > entry_close:
            return None
        return raw[i + 1:close], i + 1, close
    if raw[i] == '"':
        j = i + 1
        while j < len(raw) and raw[j] != '"':
            j += 1
        if j >= len(raw) or j > entry_close:
            return None
        return raw[i + 1:j], i + 1, j
    return None


def hyperlink(url: str, text: str = None) -> str:
    """Wrap `url` in an OSC 8 terminal hyperlink so it's a clickable target in
    modern terminals (iTerm2, recent Terminal.app, VS Code, ...). Falls back to
    the plain URL when stdout isn't a TTY (e.g. piped to a file), so logs stay
    clean. `text` defaults to the URL itself."""
    if not url:
        return url
    if not sys.stdout.isatty():
        return text or url
    return f"\033]8;;{url}\033\\{text or url}\033]8;;\033\\"


def atomic_write(path: pathlib.Path, text: str):
    """Write via a temp file + os.replace so a crash mid-write can't leave the
    target half-written / corrupted."""
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


# --- check 1: broken file links (folded in from check_broken_files.py) ------
_entry_key_re = re.compile(r"^@\w+\{(\S+),", re.MULTILINE)
_file_field_re = re.compile(r"file\s*=\s*\{([^}]*)\}", re.IGNORECASE)


def check_broken_files(raw: str):
    """Print the key of every entry whose `file` field links a path that does
    not exist on disk. JabRef stores links as `:PATH:type`, possibly several
    ;-separated; we test every component that looks like a path."""
    print("=== broken file links ===", flush=True)
    broken = 0
    for entry in re.split(r"(?=^@)", raw, flags=re.MULTILINE):
        km = _entry_key_re.match(entry)
        if not km:
            continue
        key = km.group(1).rstrip(",")
        fm = _file_field_re.search(entry)
        if not fm:
            continue
        paths = [p.strip() for p in fm.group(1).split(":") if "/" in p]
        if any(not os.path.exists(p) for p in paths):
            print(key, flush=True)
            broken += 1
    print(f"  {broken} entr{'y' if broken == 1 else 'ies'} with a broken "
          f"file link\n", flush=True)


# --- check 5: PubPeer comments ----------------------------------------------
_url_field_re = re.compile(r"\burl\s*=\s*\{([^}]*)\}", re.IGNORECASE)
_doi_field_re = re.compile(r"\bdoi\s*=\s*\{([^}]*)\}", re.IGNORECASE)
# A bare DOI suffix, used to normalise a doi field that already holds a full URL.
_doi_core_re = re.compile(r"10\.\d{4,9}/\S+")

# Public v3 endpoint the PubPeer browser extension uses: POST a batch of DOIs,
# get back one "feedbacks" object per DOI that has comments (a DOI with none is
# simply omitted). No personal API key required.
PUBPEER_API = "https://pubpeer.com/v3/publications?devkey=1"
PUBPEER_BATCH = 50          # DOIs per request
PUBPEER_TIMEOUT = 30


def check_pubpeer(raw):
    """Report every cited DOI that carries comments on PubPeer -- post-
    publication peer review that often flags a retraction, data problem, or
    correction worth knowing about before citing. Read-only and report-only;
    network-bound. DOIs are batched to PubPeer's public v3 endpoint (the one the
    browser extension uses, so no API key); DOIs with no comments come back
    omitted. Skipped with --no-pubpeer."""
    print("=== pubpeer comments ===", flush=True)
    if NO_PUBPEER:
        print("  skipped (--no-pubpeer)\n", flush=True)
        return
    import json
    import time
    import urllib.request

    # doi (lowercased bare suffix) -> citation key, first-seen order. A doi field
    # already holding a full URL is normalised down to its 10.* core.
    doi_key = {}
    for entry in re.split(r"(?=^@)", raw, flags=re.MULTILINE):
        km = _entry_key_re.match(entry)
        if not km:
            continue
        dm = _doi_field_re.search(entry)
        if not dm or not dm.group(1).strip():
            continue
        cm = _doi_core_re.search(dm.group(1).strip())
        if cm:
            doi_key.setdefault(cm.group(0).lower().rstrip("."),
                               km.group(1).rstrip(","))

    if not doi_key:
        print("  no doi fields found\n", flush=True)
        return
    dois = list(doi_key)
    print(f"  checking {len(dois)} DOIs against PubPeer "
          f"({PUBPEER_BATCH} per request)...", flush=True)

    flagged = []
    for i in range(0, len(dois), PUBPEER_BATCH):
        batch = dois[i:i + PUBPEER_BATCH]
        # A browser-like UA is required: PubPeer 403s the default urllib agent.
        req = urllib.request.Request(
            PUBPEER_API, data=json.dumps({"dois": batch}).encode(),
            headers={"Content-Type": "application/json", "User-Agent": LINK_UA})
        try:
            with urllib.request.urlopen(req, timeout=PUBPEER_TIMEOUT) as r:
                data = json.load(r)
        except Exception as e:
            print(f"  ! batch {i // PUBPEER_BATCH + 1} failed: {e}", flush=True)
            continue
        # PubPeer also returns records that exist but carry no actual comments
        # (total_comments == 0) -- noise here, so keep only the commented ones.
        flagged.extend(fb for fb in data.get("feedbacks", [])
                       if (fb.get("total_comments") or 0) > 0)
        time.sleep(1)                       # be polite to the API

    if not flagged:
        print("  no PubPeer comments on any cited DOI\n", flush=True)
        return
    print(f"  {len(flagged)} cited paper(s) have PubPeer comments:", flush=True)
    for fb in sorted(flagged, key=lambda x: -(x.get("total_comments") or 0)):
        key = doi_key.get((fb.get("id") or "").lower(), "?")
        n = fb.get("total_comments", "?")
        print(f"    {key}  [{n} comment(s)]  {hyperlink(fb.get('url', ''))}",
              flush=True)
    print(flush=True)


# --- check 6: live URL / DOI links ------------------------------------------

LINK_WORKERS = 16          # concurrent probes; network-bound, so oversubscribe
LINK_TIMEOUT = 20          # seconds per request
# A browser-like UA cuts down on publishers 403-ing scripted clients.
LINK_UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
           "AppleWebKit/537.36 (KHTML, like Gecko) "
           "Chrome/124.0 Safari/537.36")


def _probe(kind, target, session):
    """One liveness probe. Returns (status_code, None), or (None, error_name)
    when the request never completed (DNS failure, timeout, refused, ...).

    DOIs go through doi.org, which 3xx-redirects to the publisher when the DOI
    is registered and 404s when it isn't -- so for a DOI we deliberately do NOT
    follow the redirect: doi.org's own answer is the authoritative "valid DOI"
    signal, and stopping there sidesteps publisher bot-blocking (a 403 from the
    publisher says nothing about whether the DOI resolves). A plain `url` has no
    such resolver, so it follows redirects to the final page and falls back from
    HEAD to a streamed GET when a server rejects HEAD."""
    import requests
    try:
        if kind == "doi":
            r = session.head(target, allow_redirects=False, timeout=LINK_TIMEOUT)
            return r.status_code, None
        r = session.head(target, allow_redirects=True, timeout=LINK_TIMEOUT)
        if r.status_code == 405 or r.status_code >= 400:
            r = session.get(target, allow_redirects=True,
                            timeout=LINK_TIMEOUT, stream=True)
            r.close()
        return r.status_code, None
    except requests.RequestException as e:
        return None, type(e).__name__


def check_links(raw):
    """Probe every `url` and `doi` link and report the ones that aren't clearly
    live. Read-only and report-only: a failure flags a link for a human to
    eyeball, it never edits the file (a 403 usually means bot-blocking, not a
    bad URL). Results bucket into dead (definitely gone -- 400/404/410), review
    (blocked / timed out / 5xx -- ambiguous), and live. Skipped with
    --no-links. Probes run concurrently because each is network-bound."""
    print("=== live links ===", flush=True)
    if NO_LINKS:
        print("  skipped (--no-links)\n", flush=True)
        return
    try:
        import requests
    except Exception as e:
        print(f"  requests not available ({e}) -> skipping link check\n",
              flush=True)
        return
    import concurrent.futures

    # (key, field, target) for every url/doi field across all entries. A bare
    # DOI is resolved through doi.org; a doi field already holding a URL is used
    # as-is.
    tasks = []
    for entry in re.split(r"(?=^@)", raw, flags=re.MULTILINE):
        km = _entry_key_re.match(entry)
        if not km:
            continue
        key = km.group(1).rstrip(",")
        um = _url_field_re.search(entry)
        if um and um.group(1).strip():
            tasks.append((key, "url", um.group(1).strip()))
        dm = _doi_field_re.search(entry)
        if dm and dm.group(1).strip():
            doi = dm.group(1).strip()
            target = doi if doi.startswith("http") else f"https://doi.org/{doi}"
            tasks.append((key, "doi", target))

    if not tasks:
        print("  no url/doi fields found\n", flush=True)
        return
    print(f"  probing {len(tasks)} links ({LINK_WORKERS} at a time, "
          f"{LINK_TIMEOUT}s timeout)...", flush=True)

    session = requests.Session()
    session.headers["User-Agent"] = LINK_UA

    dead, review = [], []
    live = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=LINK_WORKERS) as ex:
        futs = {ex.submit(_probe, t[1], t[2], session): t for t in tasks}
        for fut in concurrent.futures.as_completed(futs):
            key, field, target = futs[fut]
            code, err = fut.result()
            if err is not None:                 # request never completed
                review.append((key, field, target, err))
            elif code in (400, 404, 410):       # gone / DOI not registered
                dead.append((key, field, target, str(code)))
            elif 200 <= code < 400:             # reachable; 3xx = DOI resolves
                live += 1
            else:                               # 401/403/429/5xx -- ambiguous
                review.append((key, field, target, str(code)))

    for label, rows in (("DEAD", sorted(dead)),
                        ("NEEDS REVIEW (blocked / timed out / server error)",
                         sorted(review))):
        if rows:
            print(f"  {label} ({len(rows)}):", flush=True)
            for key, field, target, why in rows:
                print(f"    {key}.{field}  [{why}]  {hyperlink(target)}",
                      flush=True)
    print(f"  {live} live, {len(dead)} dead, {len(review)} need review\n",
          flush=True)


# --- check 7: Crossref preprint -> published linkage ------------------------
# Entry types that denote not-yet-formally-published work -- a preprint or an
# unpublished manuscript. Only these are queried: a preprint is exactly the case
# where Crossref's relation.is-preprint-of can point at a later version of
# record, so checking @article/@book would just be noise.
CROSSREF_TYPES = {"unpublished", "online", "misc"}
CROSSREF_API = "https://api.crossref.org/works/"
CROSSREF_WORKERS = 8       # concurrent probes; network-bound, so oversubscribe
CROSSREF_TIMEOUT = 20      # seconds per request
# Crossref's polite pool: a mailto identifies the client for prioritised, more
# reliable service (https://api.crossref.org/swagger-ui -> "etiquette").
CROSSREF_MAILTO = "mgroeneveld@protonmail.ch"


def _crossref_published(doi, session):
    """Ask Crossref whether preprint `doi` now has a published version. Returns
    (published_doi, None) when one exists, (None, None) when the preprint has no
    recorded published version (or the DOI is unknown to Crossref), and
    (None, error) when the request itself failed. Crossref stores the journal
    version under the work's relation.is-preprint-of."""
    import requests
    url = CROSSREF_API + requests.utils.quote(doi, safe="")
    try:
        r = session.get(url, params={"mailto": CROSSREF_MAILTO},
                        timeout=CROSSREF_TIMEOUT)
    except requests.RequestException as e:
        return None, type(e).__name__
    if r.status_code == 404:
        return None, None                  # DOI not registered with Crossref
    if r.status_code != 200:
        return None, str(r.status_code)
    try:
        msg = r.json().get("message", {}) or {}
    except ValueError:
        return None, "bad-json"
    rel = msg.get("relation", {}) or {}
    pubs = rel.get("is-preprint-of") or []
    dois = [p.get("id") for p in pubs
            if p.get("id-type") == "doi" and p.get("id")]
    return (dois[0] if dois else None), None


def check_crossref(raw):
    """Report every unpublished/preprint-type entry (entry type in
    CROSSREF_TYPES) whose `doi` now has a published version of record on
    Crossref -- a preprint you cited that has since appeared in a journal and
    could be updated to the published DOI. Read-only and report-only: it flags
    entries for a human, it never edits the file. Network-bound, so DOIs are
    queried concurrently; Crossref's polite pool is used. Skipped with
    --no-crossref."""
    print("=== crossref preprint -> published ===", flush=True)
    if NO_CROSSREF:
        print("  skipped (--no-crossref)\n", flush=True)
        return
    try:
        import requests                                   # noqa: F401
    except Exception as e:
        print(f"  requests not available ({e}) -> skipping crossref check\n",
              flush=True)
        return
    import concurrent.futures

    # (key, doi) for every unpublished/preprint-type entry carrying a doi. A doi
    # field already holding a full URL is normalised down to its 10.* core.
    tasks = []
    for entry in re.split(r"(?=^@)", raw, flags=re.MULTILINE):
        tm = re.match(r"@(\w+)\s*\{", entry)
        if not tm or tm.group(1).lower() not in CROSSREF_TYPES:
            continue
        km = _entry_key_re.match(entry)
        if not km:
            continue
        dm = _doi_field_re.search(entry)
        if not dm or not dm.group(1).strip():
            continue
        cm = _doi_core_re.search(dm.group(1).strip())
        if cm:
            tasks.append((km.group(1).rstrip(","), cm.group(0).rstrip(".")))

    if not tasks:
        print("  no unpublished/preprint entries with a doi found\n", flush=True)
        return
    print(f"  checking {len(tasks)} preprint DOI(s) against Crossref "
          f"({CROSSREF_WORKERS} at a time, {CROSSREF_TIMEOUT}s timeout)...",
          flush=True)

    session = requests.Session()
    session.headers["User-Agent"] = f"{LINK_UA} (mailto:{CROSSREF_MAILTO})"

    published, errors = [], []
    with concurrent.futures.ThreadPoolExecutor(
            max_workers=CROSSREF_WORKERS) as ex:
        futs = {ex.submit(_crossref_published, doi, session): (key, doi)
                for key, doi in tasks}
        for fut in concurrent.futures.as_completed(futs):
            key, doi = futs[fut]
            pub, err = fut.result()
            if err is not None:
                errors.append((key, doi, err))
            elif pub:
                published.append((key, doi, pub))

    if published:
        print(f"  PUBLISHED ({len(published)}) -- preprint now has a version "
              f"of record:", flush=True)
        for key, doi, pub in sorted(published):
            print(f"    {key}  {doi} -> "
                  f"{hyperlink('https://doi.org/' + pub, pub)}", flush=True)
    if errors:
        print(f"  ERRORS ({len(errors)}):", flush=True)
        for key, doi, why in sorted(errors):
            print(f"    {key}  {doi}  [{why}]", flush=True)
    if not published:
        print("  no cited preprint has a published version on Crossref",
              flush=True)
    print(flush=True)


# --- check 2, step a: title-casing (folded in from title_case.py) -----------
# Lowercase Greek letters (α–ω, incl. final sigma ς); titlecase would otherwise
# uppercase a leading one ("α-lipoic" -> "Α-Lipoic").
_GREEK_LOWER = re.compile(r"[α-ω]")


def _greek_safe(word, **kwargs):
    """titlecase callback: title-case `word` normally but keep every lowercase
    Greek letter exactly as written, so "α-lipoic" -> "α-Lipoic". Returns None
    (let titlecase decide) for words without a lowercase Greek letter."""
    if not _GREEK_LOWER.search(word):
        return None
    cased = titlecase(word)                      # bare call: no callback, no recursion
    if len(cased) != len(word):                  # length shifted -> don't risk it
        return None
    return "".join(o if _GREEK_LOWER.match(o) else c
                   for o, c in zip(word, cased))


def titlecase_value(text: str) -> str:
    """Title-case a BibTeX field value while preserving {braced} groups (which
    protect capitalization) and \\command{...} units. Returns `text` unchanged
    if the `titlecase` package isn't installed."""
    if titlecase is None:
        return text
    placeholders = {}
    counter = 0

    def replace_braced(match):
        nonlocal counter
        # Word-safe placeholder that won't break titlecase tokenization.
        key = f"BRACEHOLD{counter}X"
        placeholders[key] = match.group(0)
        counter += 1
        return key

    # Pull out all {braced groups}, handling nesting from innermost out.
    protected = text
    while "{" in protected:
        # Match \command{...} as a unit, OR a standalone {...}.
        new = re.sub(r"\\[a-zA-Z]+\{[^{}]*\}|\{[^{}]*\}",
                     replace_braced, protected)
        if new == protected:
            break
        protected = new

    result = titlecase(protected, callback=_greek_safe)

    # Restore braced groups. Restoration repeats until no placeholder remains:
    # nested groups (e.g. {\textit{R}-MDMA}) protect inner groups first, so an
    # outer placeholder's text re-introduces inner placeholders when expanded.
    # Matching is case-insensitive (titlecase() may re-case the placeholder);
    # the trailing "X" keeps BRACEHOLD1X from matching inside BRACEHOLD11X. A
    # function replacement is used so backslashes in the original (e.g.
    # \emph{...}) aren't interpreted as regex escape sequences.
    while True:
        before = result
        for key, val in placeholders.items():
            result = re.sub(re.escape(key), lambda m, v=val: v, result,
                            flags=re.IGNORECASE)
        if result == before:
            break
    return result


# --- check 2: layout cleanup via biber --tool -------------------------------
def format_bib():
    """Reformat references.bib with `biber --tool` for consistent layout, and
    strip JabRef @comment metadata. biber is biblatex-aware (bibcop is not: it
    can't parse @online/date and aborts the whole file). biber --tool is
    deterministic and trusted, so its output replaces the file directly without
    verifying entry keys or brace balance. No-op under --dry-run or
    --no-format."""
    if NO_FORMAT:
        return
    biber = shutil.which("biber")
    if not biber:
        print("biber not found -> skipping layout cleanup", flush=True)
        return

    before = BIB.read_text(encoding="utf-8")

    with tempfile.TemporaryDirectory() as td:
        td = pathlib.Path(td)
        src, out = td / "in.bib", td / "out.bib"
        src.write_text(before, encoding="utf-8")
        cmd = [biber, "--tool", "--quiet", "--nodieonerror",
               "--input-encoding=UTF-8", "--output-encoding=UTF-8",
               "--output-align", "--output-indent=2",
               "--output-fieldcase=lower", f"--output-file={out}", str(src)]
        # cwd=td so biber's .blg log lands in the temp dir and is auto-cleaned.
        try:
            r = subprocess.run(cmd, cwd=td, capture_output=True, text=True,
                               timeout=300)
        except Exception as e:
            print(f"biber failed to run ({e}) -> layout unchanged", flush=True)
            return
        if not out.is_file() or not out.read_text(encoding="utf-8").strip():
            print("biber produced no output -> layout unchanged"
                  f"\n  {(r.stderr or '').strip()[:300]}", flush=True)
            return
        formatted = out.read_text(encoding="utf-8")

    # Drop @comment entries (e.g. JabRef metadata) -- not needed.
    formatted = re.sub(r"(?is)@comment\{.*?\}\s*", "", formatted).lstrip("\n")

    if formatted == before:
        print("layout already clean.", flush=True)
        return
    if DRY_RUN:
        print("[dry-run] would reformat via biber --tool", flush=True)
        return
    atomic_write(BIB, formatted)
    print("layout cleanup: reformatted via biber --tool.", flush=True)


# --- check 3: data-model validation via biber --validate-datamodel ----------
def validate_datamodel():
    """Report-only biblatex data-model validation. Re-runs the file through
    `biber --tool --validate-datamodel` (the SAME biblatex-aware tool as the
    layout pass, so it understands @online/@unpublished/date/journaltitle that a
    BibTeX-only linter would reject) and surfaces the WARN lines from biber's
    .blg log: missing required fields, unknown fields, malformed dates. The
    reformatted output is discarded -- nothing is edited. Skip with
    --no-validate."""
    print("=== data-model validation ===", flush=True)
    if NO_VALIDATE:
        print("  skipped (--no-validate)\n", flush=True)
        return
    biber = shutil.which("biber")
    if not biber:
        print("  biber not found -> skipping validation\n", flush=True)
        return

    with tempfile.TemporaryDirectory() as td:
        td = pathlib.Path(td)
        src, out, log = td / "in.bib", td / "out.bib", td / "validate.blg"
        src.write_text(BIB.read_text(encoding="utf-8"), encoding="utf-8")
        cmd = [biber, "--tool", "--validate-datamodel", "--nodieonerror",
               "--input-encoding=UTF-8", "--output-encoding=UTF-8",
               f"--output-file={out}", f"--logfile={log}", str(src)]
        try:
            subprocess.run(cmd, cwd=td, capture_output=True, text=True,
                           timeout=300)
        except Exception as e:
            print(f"  biber failed to run ({e}) -> validation skipped\n",
                  flush=True)
            return
        blg = (log.read_text(encoding="utf-8", errors="replace")
               if log.is_file() else "")

    # One WARN line per violation; strip biber's "[time] File.pm:NN> WARN - "
    # prefix and keep the message. Drop the temp path biber echoes back.
    warns = []
    for ln in blg.splitlines():
        idx = ln.find("WARN - ")
        if idx != -1:
            warns.append(ln[idx + len("WARN - "):].strip())
    if not warns:
        print("  no data-model warnings\n", flush=True)
        return
    print(f"  {len(warns)} data-model warning(s):", flush=True)
    for w in warns:
        print(f"    {w}", flush=True)
    print(flush=True)


# --- check 4: offline entry sanity checks -----------------------------------
# Small stop-word set for fuzzy title comparison; mirrors the words biblint
# drops when detecting duplicate titles.
_STOPWORDS = {"a", "an", "the", "of", "on", "in", "and", "or", "for", "to",
              "with", "from", "by", "at", "as", "is", "are", "be"}


def _norm_title(value: str) -> str:
    """Fold a title to a comparison key: drop \\commands, reduce everything but
    letters/digits to single spaces, lowercase, and drop stop-words. Two entries
    sharing a key are very likely the same work cited twice."""
    s = re.sub(r"\\[a-zA-Z]+", " ", value)          # \emph etc. -> space
    s = re.sub(r"[^0-9A-Za-z]+", " ", s).lower()    # braces/punct -> space
    return " ".join(t for t in s.split() if t not in _STOPWORDS)


def check_entries(raw):
    """Offline, report-only sanity checks over every entry -- the biblatex-
    correct half of biblint's `check`, run across ALL entry types:

      - duplicate citation keys
      - near-duplicate titles (same work under two keys)
      - page ranges with a single hyphen ("12-15") or reversed bounds ("15--12")
      - non-integer year / date not starting with a 4-digit year

    Deterministic, no network, no edits: every finding is flagged for a human."""
    print("=== entry sanity checks ===", flush=True)

    keys = []
    for m in re.finditer(r"@(\w+)\s*\{\s*([^,\s]+)\s*,", raw):
        if m.group(1).lower() in ("comment", "string", "preamble"):
            continue
        keys.append(m.group(2))

    key_counts = Counter(keys)
    dup_keys = sorted(k for k, c in key_counts.items() if c > 1)
    unique_keys = list(dict.fromkeys(keys))

    titles = {}
    bad_pages, bad_years = [], []
    for key in unique_keys:
        tinfo = get_field(raw, key, "title")
        if tinfo:
            norm = _norm_title(tinfo[0])
            if len(norm) >= 8:                  # too short to compare reliably
                titles.setdefault(norm, []).append(key)

        pinfo = get_field(raw, key, "pages")
        if pinfo:
            pv = pinfo[0].strip()
            if re.search(r"\d\s*-\s*\d", pv) and "--" not in pv:
                bad_pages.append((key, pv, "single hyphen (use --)"))
            else:
                rm = re.match(r"^(\d+)\s*-+\s*(\d+)$", pv)
                # len(b) >= len(a) skips abbreviated ranges like "1234--56".
                if rm and len(rm.group(2)) >= len(rm.group(1)) \
                        and int(rm.group(1)) > int(rm.group(2)):
                    bad_pages.append((key, pv, "reversed range"))

        yinfo = get_field(raw, key, "year")
        if yinfo and yinfo[0].strip() \
                and not re.fullmatch(r"\d{4}", yinfo[0].strip()):
            bad_years.append((key, f"year={yinfo[0].strip()}"))
        dinfo = get_field(raw, key, "date")
        if dinfo and dinfo[0].strip() \
                and not re.match(r"^\d{4}\b", dinfo[0].strip()):
            bad_years.append((key, f"date={dinfo[0].strip()}"))

    dup_titles = sorted(sorted(v) for v in titles.values() if len(v) > 1)

    issues = 0
    if dup_keys:
        issues += len(dup_keys)
        print(f"  DUPLICATE KEYS ({len(dup_keys)}):", flush=True)
        for k in dup_keys:
            print(f"    {k}  (x{key_counts[k]})", flush=True)
    if dup_titles:
        issues += len(dup_titles)
        print(f"  NEAR-DUPLICATE TITLES ({len(dup_titles)}):", flush=True)
        for grp in dup_titles:
            print(f"    {', '.join(grp)}", flush=True)
    if bad_pages:
        issues += len(bad_pages)
        print(f"  PAGE RANGES ({len(bad_pages)}):", flush=True)
        for k, v, why in sorted(bad_pages):
            print(f"    {k}: {v}  [{why}]", flush=True)
    if bad_years:
        issues += len(bad_years)
        print(f"  YEAR / DATE ({len(bad_years)}):", flush=True)
        for k, v in sorted(bad_years):
            print(f"    {k}: {v}", flush=True)
    if issues == 0:
        print("  no issues found", flush=True)
    print(flush=True)


# --- main -------------------------------------------------------------------
raw = BIB.read_text(encoding="utf-8")

check_broken_files(raw)

# Layout cleanup runs before proof-reading so the model pass operates on the
# biber-formatted file; re-read `raw` afterwards to pick up the reformat.
print("=== layout cleanup ===", flush=True)
format_bib()
raw = BIB.read_text(encoding="utf-8")

# Validation and the offline sanity checks run on the cleaned-up file. Both are
# report-only; the fast offline checks run before the network-bound link probe.
validate_datamodel()
check_entries(raw)

# PubPeer and live-link checks both run on the cleaned-up file, before the title
# pass. PubPeer first so any flagged paper surfaces before the longer link probe.
check_pubpeer(raw)
check_links(raw)

# Crossref preprint -> published linkage, on the same cleaned-up file. Runs
# after the link probe and before the title pass; report-only, network-bound.
check_crossref(raw)

print("=== title proof-reading ===", flush=True)
print(f"  word list: {len(TERMS)} terms; "
      f"{len(COMMON_WORDS)} common words for the guard", flush=True)

# Collect (key, field) tasks. Keys are read once; values are re-located from the
# live `raw` at edit time, so insertions/edits never invalidate a stored offset.
keys = []
for m in re.finditer(r"@(\w+)\s*\{\s*([^,\s]+)\s*,", raw):
    if m.group(1).lower() in ("comment", "string", "preamble"):
        continue
    keys.append(m.group(2))

tasks = [(k, f) for k in keys for f in FIELDS if get_field(raw, k, f)]
if LIMIT:
    tasks = tasks[:LIMIT]

stats = {"fixed": 0, "unchanged": 0, "rejected": 0}
log_lines = []
for i, (key, field) in enumerate(tasks, 1):
    info = get_field(raw, key, field)
    if not info:                      # vanished after an earlier edit (unlikely)
        continue
    value, vstart, vend = info

    new, reason = protect_caps(value)
    if new is None:                   # unchanged, or rejected by the brace check
        if reason == "unchanged":
            stats["unchanged"] += 1
        else:
            stats["rejected"] += 1
            print(f"{key}.{field}: skipped ({reason})", flush=True)
        continue

    stats["fixed"] += 1
    print(f"[{i}/{len(tasks)}] {key}.{field}: FIXED", flush=True)
    print(f"    - {value}", flush=True)
    print(f"    + {new}", flush=True)
    log_lines.append(f"{key}\t{field}\n  - {value}\n  + {new}")
    if not DRY_RUN:
        raw = raw[:vstart] + new + raw[vend:]
        atomic_write(BIB, raw)
        LOG.write_text("\n".join(log_lines) + "\n", encoding="utf-8")

if log_lines and not DRY_RUN:
    LOG.write_text("\n".join(log_lines) + "\n", encoding="utf-8")

print(f"\n{'[dry-run] ' if DRY_RUN else ''}done (deterministic capitalization"
      f"{'' if titlecase else '; titlecase package missing -> casing skipped'}).")
print(f"  fixed     : {stats['fixed']}")
print(f"  unchanged : {stats['unchanged']}")
print(f"  rejected  : {stats['rejected']}  (left unchanged)")
if not DRY_RUN and stats["fixed"]:
    print(f"  changes logged to {LOG.name}")
