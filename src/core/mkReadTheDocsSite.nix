{ repoRoot, pkgs, lib, user-inputs, ... }:

readTheDocs:
combined-haddock:

let

  site = pkgs.stdenv.mkDerivation {

    name = "read-the-docs-site";

    src = lib.sourceFilesBySuffices
      (user-inputs.self + "/${readTheDocs.siteFolder}")
      [ ".py" ".rst" ".md" ".hs" ".png" ".svg" ".bib" ".csv" ".css" ".html" ".txt" ];

    buildInputs = [
      readTheDocs.sphinxToolchain
      # We need this here in order to get the `plantuml` executable in PATH.
      # Unfortunately `python3.withPackages` (used by sphinx-toolchain above)
      # won't do it automatically.
      readTheDocs.sphinxToolchain.pkgs.sphinxcontrib_plantuml
      # pkgs.python3Packages.sphinxcontrib_plantuml
    ];

    dontInstall = true;

    buildPhase = ''
      cp -aR ${combined-haddock}/share/doc haddock
      # -n gives warnings on missing link targets, -W makes warnings into errors
      SPHINX_HADDOCK_DIR=haddock sphinx-build -W -n . $out
      cp -aR haddock $out
    '';
  };


  dummySite = pkgs.runCommand "dummy-read-the-docs-site" { } ''
    mkdir -p $out
    echo "This is a dummy read-the-docs site." > $out/index.html
  '';

in

if readTheDocs.enable then site else dummySite
