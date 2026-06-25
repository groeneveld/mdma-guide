#!/usr/bin/env python3
"""Proof-read selected fields of references.bib with a local MLX model.

For every entry, the title-like fields

    title, booktitle, eventtitle, journaltitle

are sent to a small local model (mlx-community/gemma-4-E2B-it-OptiQ-4bit) which:

  1. fixes spelling mistakes and formatting errors (stray spaces, broken
     hyphenation, mis-rendered ligatures, mangled capitalization of ordinary
     words), without rewording or translating; and
  2. wraps every proper noun, acronym, and initialism in curly braces so the
     bibliography style can't lowercase them (e.g. MDMA -> {MDMA}), ensuring
     each is correctly capitalized inside the braces.

Nothing leaves the machine. The .bib is edited by targeted, balanced-brace
replacement (not full re-serialization), so the diff is limited to the field
values that actually changed, and the file is atomically rewritten after every
single correction -- a crash mid-run leaves a valid file with all prior fixes
intact. Every change is appended to bib_fixes.txt.

Usage:
    python3 fix_bib.py [--dry-run] [--limit N]

Run from the repo root or auxillaryFiles/; paths resolve relative to the script.
"""
import os
import re
import sys
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent
BIB = REPO / "references.bib"
LOG = HERE / "bib_fixes.txt"

DRY_RUN = "--dry-run" in sys.argv
LIMIT = None
if "--limit" in sys.argv:
    LIMIT = int(sys.argv[sys.argv.index("--limit") + 1])

# Fields whose contents are human-readable titles worth proof-reading.
FIELDS = ["title", "booktitle", "eventtitle", "journaltitle"]

MLX_MODEL = "mlx-community/gemma-4-E2B-it-OptiQ-4bit"
# Reasoning model: it emits chain-of-thought before the answer, so the ceiling
# must cover both. Titles are short, but the reasoning is not, so leave room.
MLX_MAX_TOKENS = 2048
_MLX = {}   # model_name -> (model, tokenizer), loaded lazily

PROMPT = (
    "You are proof-reading a single BibTeX field value: the {field} of a "
    "bibliography entry. Apply ONLY these changes and output the corrected "
    "value:\n"
    "1. Fix genuine spelling mistakes and formatting errors: stray or missing "
    "spaces, broken hyphenation, mis-rendered ligatures (e.g. garbled fi/fl), "
    "and ordinary words that are wrongly capitalized.\n"
    "2. Do NOT translate, paraphrase, reword, reorder, expand, abbreviate, or "
    "shorten anything. Keep the exact same words in the exact same order.\n"
    "3. Wrap every proper noun, acronym, initialism, gene/drug/chemical name, "
    "and brand name in curly braces so its capitalization is preserved, and "
    "make sure it is correctly capitalized inside the braces (e.g. mdma -> "
    "{MDMA}, ptsd -> {PTSD}, parkinson -> {Parkinson}). If a term is already "
    "wrapped in braces, leave the braces. Do NOT wrap ordinary words.\n"
    "Output ONLY the corrected field value on a single line: no quotation "
    "marks, no trailing comma, no explanation, no preamble."
)


# --- MLX (mirrors add_abstracts.py) -----------------------------------------
def ensure_mlx(model_name: str):
    """Load an MLX model + tokenizer once, on first use, caching per model."""
    if model_name not in _MLX:
        try:
            from mlx_lm import load
        except Exception as e:
            print(f"    mlx-import-failed: {e}", flush=True)
            return None
        print(f"loading {model_name}...", flush=True)
        _MLX[model_name] = load(model_name)
    return _MLX[model_name]


def strip_reasoning(text: str):
    """Drop this model's chain-of-thought and return only the final answer.
    Reasoning is wrapped in plain-text channel delimiters; the answer follows
    the final closing `<channel|>`. If a channel was opened but never closed,
    the answer was cut off -> (None, 'truncated')."""
    if "<channel|>" in text:                       # closed -> answer present
        text = text.rsplit("<channel|>", 1)[-1]
    elif "<|channel>" in text:                      # opened, never closed
        return None, "truncated"
    text = re.sub(r"<\|?/?(channel|tool_call|tool_response|turn)\|?>", "", text)
    return text.strip(), None


def mlx_run(model_name: str, prompt: str, content: str, max_tokens: int):
    """Run one chat completion. Returns (text, None) or (None, reason)."""
    loaded = ensure_mlx(model_name)
    if loaded is None:
        return None, "mlx-unavailable"
    model, tok = loaded
    from mlx_lm import generate
    from mlx_lm.sample_utils import make_sampler
    messages = [{"role": "user",
                 "content": f"{prompt}\n\n--- BEGIN VALUE ---\n"
                            f"{content}\n--- END VALUE ---"}]
    prompt_ids = tok.apply_chat_template(messages, add_generation_prompt=True)
    try:
        out = generate(model, tok, prompt=prompt_ids, max_tokens=max_tokens,
                       sampler=make_sampler(temp=0.0))
    except Exception as e:
        return None, f"mlx-error: {e}"
    return strip_reasoning(out)


def fix_value(field: str, value: str):
    """Proof-read one field value. Returns (corrected, None) or (None, reason).
    Returns ('', None)-style no-op as (None, 'unchanged') when nothing changed
    or the result fails a sanity check, so the caller leaves the file alone."""
    out, err = mlx_run(MLX_MODEL, PROMPT.format(field=field), value,
                       MLX_MAX_TOKENS)
    if err:
        return None, err
    if not out:
        return None, "empty"
    # Strip wrapper noise the model sometimes adds despite instructions.
    out = out.strip().strip("`").strip()
    if len(out) >= 2 and out[0] == '"' and out[-1] == '"':
        out = out[1:-1].strip()
    out = re.sub(r"\s+", " ", out).strip().rstrip(",").strip()

    if not out or out.upper() == "NONE":
        return None, "empty"
    if out == value:
        return None, "unchanged"
    # Reject obviously broken output: unbalanced braces would corrupt the entry.
    if out.count("{") != out.count("}"):
        return None, "unbalanced-braces"
    # Reject hallucinated rewrites that drift too far in length from the source.
    if len(out) < 0.5 * len(value) or len(out) > 2.0 * len(value) + 10:
        return None, "length-drift"
    return out, None


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


def atomic_write(path: pathlib.Path, text: str):
    """Write via a temp file + os.replace so a crash mid-write can't leave the
    target half-written / corrupted."""
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


# --- main -------------------------------------------------------------------
raw = BIB.read_text(encoding="utf-8")

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

stats = {"fixed": 0, "unchanged": 0, "skipped": 0}
log_lines = []
for i, (key, field) in enumerate(tasks, 1):
    info = get_field(raw, key, field)
    if not info:                      # vanished after an earlier edit (unlikely)
        continue
    value, vstart, vend = info
    new, reason = fix_value(field, value)
    if new is None:
        tag = "UNCHANGED" if reason == "unchanged" else f"SKIP ({reason})"
        if reason == "unchanged":
            stats["unchanged"] += 1
        else:
            stats["skipped"] += 1
        print(f"[{i}/{len(tasks)}] {key}.{field}: {tag}", flush=True)
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

print(f"\n{'[dry-run] ' if DRY_RUN else ''}done (model: {MLX_MODEL}).")
print(f"  fixed     : {stats['fixed']}")
print(f"  unchanged : {stats['unchanged']}")
print(f"  skipped   : {stats['skipped']}")
if not DRY_RUN and stats["fixed"]:
    print(f"  changes logged to {LOG.name}")
