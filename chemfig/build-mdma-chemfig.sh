#!/bin/bash
set -e
cd "$(dirname "$0")"

lualatex -interaction=nonstopmode mdma-chemfig.tex
rm -f mdma-chemfig.aux mdma-chemfig.log
pdf2svg mdma-chemfig.pdf mdma-chemfig.svg
