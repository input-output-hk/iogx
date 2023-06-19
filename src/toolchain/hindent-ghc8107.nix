{ pkgs, ... }:
let
  project = pkgs.haskell-nix.hackage-project {
    name = "hindent";

    version = "5.3.4";

    compiler-nix-name = "ghc8107";

    index-state = "2023-03-05T00:00:00Z";
  };
in
project.hsPkgs.hindent.components.exes.hindent
