{ pkgs, ... }:

let

  project = pkgs.haskell-nix.hackage-project {
    name = "cabal-install";

    version = "3.10.1.0";

    compiler-nix-name = "ghc96";

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
