# Normally we would want to get fourmolu from HLS, so as to have the same version
# both in HLS and in pre-commit-check. However the fourmolu provided by HLS is 
# too old for our needs, and so we build it from source.
{ pkgs, ... }:

let
  project = pkgs.haskell-nix.hackage-project {
    name = "fourmolu";
    version = "0.16.2.0";
    compiler-nix-name = "ghc982";

    modules = [{
      packages.fourmolu.components.exes.fourmolu.dontStrip = false;
    }];
  };

in

project.hsPkgs.fourmolu.components.exes.fourmolu
