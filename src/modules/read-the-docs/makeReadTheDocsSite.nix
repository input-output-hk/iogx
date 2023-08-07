{ src, pkgs, iogx-interface, user-repo-root, inputs, inputs', l, ... }:

let

  read-the-docs =
    iogx-interface."read-the-docs.nix".load { inherit inputs inputs' pkgs; };


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

    buildPhase = ''
      sphinx-build -W -n . $out
    '';
  };

in

if read-the-docs.siteFolder == null then null else read-the-docs-site

