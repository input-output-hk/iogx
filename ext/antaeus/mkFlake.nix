{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake { } {
    repoRoot = iogx-inputs.antaeus;
    nixFolder = ./nix;
    shellName = "antaeus";
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    haskell.compilers = [ "ghc8107" ];
    crossSystem = "x86_64-linux";
  };
in
flake
