{ pkgs, ... }:
let
  project = pkgs.haskell-nix.hackage-project {
    name = "cabal-install";

    version = "3.8.1.0";

    compiler-nix-name = "ghc925";

    index-state = "2023-03-05T00:00:00Z";

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";
  };
in
project.hsPkgs.cabal-install.components.exes.cabal
