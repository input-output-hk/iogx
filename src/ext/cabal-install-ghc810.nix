{ pkgs, ... }:

let

  project = pkgs.haskell-nix.hackage-project {
    name = "cabal-install";

    version = "3.6.2.0";

    compiler-nix-name = "ghc810";

    index-state = "2023-03-05T00:00:00Z";
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
