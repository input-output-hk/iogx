{ pkgs, src, l, user-repo-root, ... }:

{ rtd-config }:

pkgs.stdenv.mkDerivation {

  name = "read-the-docs-site";

  src = l.sourceFilesBySuffices "${user-repo-root}/${rtd-config.siteRoot}"
    [ ".py" ".rst" ".md" ".hs" ".png" ".svg" ".bib" ".csv" ".css" ".html" "txt" ];

  buildInputs = [
    src.read-the-docs.sphinx-toolchain
    # We need this here in order to get the `plantuml` executable in PATH.
    # Unfortunately `python3.withPackages` (used by sphinx-toolchain above)
    # won't do it automatically.
    pkgs.python3Packages.sphinxcontrib_plantuml
  ];

  dontInstall = true;

  buildPhase = ''
    sphinx-build -W -n . $out
  '';
}