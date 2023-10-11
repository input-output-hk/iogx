{ pkgs, lib, ... }:

ghc:

let

  version =
    if lib.hasInfix "ghc810" ghc then
      "3.6.2.0"
    else
      "3.10.1.0";


  project = pkgs.haskell-nix.hackage-project {

    name = "cabal-install";

    # inherit version;
    version = "3.10.1.0";

    compiler-nix-name = ghc;

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
