{ pkgs, lib, ... }:

ghc:

pkgs.haskell-nix.tool ghc "cabal-install" "latest"
