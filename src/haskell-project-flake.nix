{ pkgs, haskell-project, haskell-project-shell }:

let
  flake = pkgs.haskell-nix.haskellLib.mkFlake haskell-project {

    devShell = haskell-project-shell;

  };

in
flake
