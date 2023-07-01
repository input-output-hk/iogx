# Normally we would want to get fourmolu from HLS, so as to have the same version
# both in HLS and in pre-commit-check. However the fourmolu provided by HLS is 
# too old for our needs, and so we build it from source.
{ pkgs, ... }:
let
  project = pkgs.haskell-nix.hackage-project {
    name = "fourmolu";
    version = "0.13.0.0";
    compiler-nix-name = "ghc927";

    # Otherwise it would use aeson-2.2.0.0 which no longer exports 
    # Data.Aeson.Internal, which in turn breask yaml-0.11.11.1
    cabalProjectLocal = '' 
      constraints: aeson==2.1.2.1
    '';
  };
in
project.hsPkgs.fourmolu.components.exes.fourmolu
