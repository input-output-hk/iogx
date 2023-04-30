{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake {
    inputs = { self = flake; };
    repoRoot = iogx-inputs.marconi;
    shellName = "marconi";
    haskellProjectFile = import ./nix/haskell-project.nix;
  };
in
flake
