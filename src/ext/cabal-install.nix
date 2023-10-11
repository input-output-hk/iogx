{ pkgs, lib, ... }:

ghc:

let

  version =
    if lib.hasInfix "ghc810" ghc then
      "3.6.2.0"
    else if lib.hasInfix "ghc92" ghc then
      "3.10.1.0"
    else
      "3.10.1.0";


  project = pkgs.haskell-nix.hackage-project {

    name = "cabal-install";

    inherit version;

    compiler-nix-name = ghc;

    # index-state = "2023-03-05T00:00:00Z";

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
