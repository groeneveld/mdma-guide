sed -n '/^% BEGIN_PLAIN_SUMMARY/,/^% END_PLAIN_SUMMARY/p' paper.tex \
  | sed '1d;$d' \
  | sed 's/\\mdcite{/\\citep{/g' \
  | perl -0pe 's/\\mdonly\{((?:[^{}]++|\{(?:[^{}]++|\{[^{}]*\})*\})*)\}/$1/g' \
  | pandoc \
      --citeproc \
      --bibliography=references.bib \
      --csl=auxillaryFiles/apa.csl \
      -f latex -t commonmark \
      -o plain-summary.md

sed -i '' -E '/^<\/div>$/d' plain-summary.md
sed -i '' -E '/^<div[^>]+>$/d' plain-summary.md
sed -i '' -E '/^<div[^>]*$/,/^[^<]*>$/d' plain-summary.md