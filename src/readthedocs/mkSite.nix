{ pkgs, iogx, flakeopts, ... }:

ghc:

pkgs.stdenv.mkDerivation {

  name = "read-the-docs-site";

  src = pkgs.lib.sourceFilesBySuffices flakeopts.readTheDocsFolder
    [ ".py" ".rst" ".hs" ".png" ".svg" ".bib" ".csv" ".css" ".md" ];

  buildInputs = [

    iogx.toolchain.sphinx-toolchain
    # We need this here in order to get the `plantuml` executable in PATH.
    # Unfortunately `python3.withPackages` (used by sphinx-toolchain above)
    # won't do it automatically.
    pkgs.python3Packages.sphinxcontrib_plantuml
  ];

  dontInstall = true;

  buildPhase = ''
    cp -aR ${iogx.readthedoc.project-haddock ghc}/share/doc haddock
    # -n gives warnings on missing link targets, -W makes warnings into errors
    SPHINX_HADDOCK_DIR=haddock sphinx-build -n -W . $out
    cp -aR haddock $out
  '';
}
