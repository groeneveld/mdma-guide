python3 auxillaryFiles/gls.py

mkdir -p temp

pdflatex -output-directory=temp "Open MDMA.tex"
biber --input-directory=temp --output-directory=temp "Open MDMA"
makeglossaries -d temp "Open MDMA"
pdflatex -output-directory=temp "Open MDMA.tex"
biber --input-directory=temp --output-directory=temp "Open MDMA"
pdflatex -output-directory=temp "Open MDMA.tex"
pdflatex -output-directory=temp "Open MDMA.tex"

mv temp/"Open MDMA.pdf" .