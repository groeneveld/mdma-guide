# latexmk configuration for Open MDMA project

# Use lualatex instead of pdflatex
$pdf_mode = 4;  # 4 = lualatex
$lualatex = 'lualatex %O %S';

# Use biber for bibliography
$biber = 'biber %O %S';
$bibtex_use = 2;

# Output directory
$out_dir = 'temp';

# Enable glossaries support
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse($_[0]);
    pushd $path;
    my $return = system "makeglossaries", $base_name;
    popd;
    return $return;
}

# Clean up additional extensions
$clean_ext = 'bbl glo gls glg acn acr alg run.xml';
