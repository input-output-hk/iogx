{ src, pkgs, nix, iogx, iogx-interface, user-repo-root, inputs, inputs', l, system, ... }:

{ combined-haddock ? null }:

let

  read-the-docs = iogx-interface."read-the-docs.nix".load
    { inherit nix iogx inputs inputs' pkgs l system; };


  read-the-docs-site = pkgs.stdenv.mkDerivation {

    name = "read-the-docs-site";

    src = l.sourceFilesBySuffices
      (user-repo-root + "/${read-the-docs.siteFolder}")
      [ ".py" ".rst" ".md" ".hs" ".png" ".svg" ".bib" ".csv" ".css" ".html" "txt" ];

    buildInputs = [
      src.modules.read-the-docs.ext.sphinx-toolchain
      # We need this here in order to get the `plantuml` executable in PATH.
      # Unfortunately `python3.withPackages` (used by sphinx-toolchain above)
      # won't do it automatically.
      pkgs.python3Packages.sphinxcontrib_plantuml
    ];

    dontInstall = true;

    buildPhase =
      if combined-haddock == null then ''
        sphinx-build -W -n . $out
      '' else ''
        cp -aR ${combined-haddock}/share/doc haddock
        # -n gives warnings on missing link targets, -W makes warnings into errors
        SPHINX_HADDOCK_DIR=haddock sphinx-build -W -n . $out
        cp -aR haddock $out
      '';
  };

in

if read-the-docs.siteFolder == null then null else read-the-docs-site

