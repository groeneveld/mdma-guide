import sys, os, re, warnings, urllib.parse, requests, trafilatura, bibtexparser
from bibtexparser.bparser import BibTexParser

warnings.filterwarnings("ignore", message="urllib3 v2 only supports OpenSSL")

BIB_PATH = "references.bib"

parser = BibTexParser(common_strings=True)
parser.ignore_nonstandard_types = False
with open(BIB_PATH) as f:
    bib_text = f.read()
bib = bibtexparser.loads(bib_text, parser=parser).entries_dict

out_dir = os.path.abspath(sys.argv[1])
os.makedirs(out_dir, exist_ok=True)

keys = [sys.argv[2]]

def filename_for(entry, key):
    author = re.sub(r"[{}]", "", entry.get("author", "")).strip()
    first = author.split(" and ")[0] if author else ""
    if "," in first:
        last = first.split(",")[0].strip()
    elif first:
        last = first.split()[-1]
    else:
        last = "unknown"
    year = (entry.get("date") or entry.get("year") or "n.d.").split("-")[0]
    title = re.sub(r"[{}]", "", entry.get("title", key))
    name = f"{last} - {year} - {title}"
    name = re.sub(r"[/\\:*?\"<>|]", "_", name)
    return name[:180] + ".txt"

def add_file_field(text, key, file_path):
    m = re.search(r"^@\w+\{" + re.escape(key) + r",\s*$", text, re.MULTILINE)
    if not m:
        return text, "entry not found in bib text"
    start = m.end()
    end_m = re.search(r"^\}", text[start:], re.MULTILINE)
    if not end_m:
        return text, "no closing brace"
    end = start + end_m.start()
    body = text[start:end]
    if re.search(r"^ file = ", body, re.MULTILINE):
        return text, "already has file field, skipping"
    stripped = body.rstrip()
    if stripped and not stripped.endswith(","):
        stripped += ","
    new_body = stripped + "\n file = {:" + file_path + ":},\n"
    return text[:start] + new_body + text[end:], "added file field"

for key in keys:
    entry = bib.get(key)
    if not entry:
        print(f"{key}: not in bib")
        continue
    url = entry.get("url")
    if not url:
        print(f"{key}: no url")
        continue
    try:
        html = requests.get(url, timeout=20).text
        text = trafilatura.extract(html)
    except Exception as e:
        print(f"{key}: fetch failed: {e}")
        continue
    if not text:
        print(f"{key}: extraction returned nothing")
        continue
    path = os.path.join(out_dir, filename_for(entry, key))
    with open(path, "w") as f:
        f.write(f"{url}\n\n{text}\n")
    bib_text, status = add_file_field(bib_text, key, path)
    uri = "file://" + urllib.parse.quote(path)
    link = f"\033]8;;{uri}\033\\{path}\033]8;;\033\\"
    print(f"{key}: {link} ({status})")

with open(BIB_PATH, "w") as f:
    f.write(bib_text)
