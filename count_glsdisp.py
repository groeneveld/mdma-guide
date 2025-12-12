#!/usr/bin/env python3
import re
from collections import Counter

# Read the file
with open("Open MDMA.tex", "r", encoding="utf-8") as f:
    content = f.read()

# Find all \glsdisp{term}{...} patterns and extract the term (first argument)
pattern = r'\\glsdisp\{([^}]+)\}'
terms = re.findall(pattern, content)

# Count occurrences
term_counts = Counter(terms)

# Print results sorted by count (descending)
print(f"Total \\glsdisp uses: {len(terms)}\n")
print(f"{'Term':<40} {'Count':>6}")
print("-" * 47)
for term, count in term_counts.most_common():
    print(f"{term:<40} {count:>6}")
