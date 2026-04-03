import re
import bibtexparser
from bibtexparser.bparser import BibTexParser
from titlecase import titlecase

TITLE_FIELDS = ['title', 'booktitle', 'eventtitle', 'journaltitle']

def titlecase_preserving_braces(text):
    """Title-case a BibTeX string while preserving {braced} groups."""
    placeholders = {}
    counter = 0

    def replace_braced(match):
        nonlocal counter
        # Word-safe placeholder that won't break tokenization
        key = f"BRACEHOLD{counter}X"
        placeholders[key] = match.group(0)
        counter += 1
        return key

    # Pull out all {braced groups}, handling nesting from innermost out
    protected = text
    while '{' in protected:
        # Match \command{...} as a unit, OR standalone {...}
        new = re.sub(
            r'\\[a-zA-Z]+\{[^{}]*\}|\{[^{}]*\}',
            replace_braced, protected
        )
        if new == protected:
            break
        protected = new

    # Title-case the unprotected text
    result = titlecase(protected)

    # Restore braced groups (longest keys first to avoid partial matches)
    # Use case-insensitive replace since titlecase() may lowercase the placeholder
    for key in sorted(placeholders, key=len, reverse=True):
        result = re.sub(re.escape(key), placeholders[key], result, flags=re.IGNORECASE)

    return result

parser = BibTexParser(common_strings=True)
parser.ignore_nonstandard_types = False

with open('references.bib') as f:
    db = bibtexparser.load(f, parser=parser)

for entry in db.entries:
    for field in TITLE_FIELDS:
        if field in entry:
            entry[field] = titlecase_preserving_braces(entry[field])

with open('references.bib', 'w') as f:
    bibtexparser.dump(db, f)