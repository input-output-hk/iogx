{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake { } {
    repoRoot = iogx-inputs.marconi;
    shellName = "marconi";
    nixFolder = ./nix;
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    haskell.compilers = [ "ghc8107" ];
  };
in
flake


