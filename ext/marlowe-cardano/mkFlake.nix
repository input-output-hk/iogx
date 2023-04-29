{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake { self = flake; } {
    repoRoot = iogx-inputs.marlowe-cardano;
    shellName = "marlowe-cardano";
    nixFolder = ./nix;
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    haskell.compilers = [ "ghc8107" ];
  };
in
flake
