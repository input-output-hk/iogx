{ pkgs, ... }:
let
  project = pkgs.haskell-nix.hackage-project {
    name = "hindent";

    version = "6.1.0";

    compiler-nix-name = "ghc927";

    index-state = "2023-03-05T00:00:00Z";
  };
in
project.hsPkgs.hindent.components.exes.hindent
