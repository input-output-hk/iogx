{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake {
    inputs = { self = flake; };
    repoRoot = iogx-inputs.marlowe-cardano;
    shellName = "marlowe-cardano";
    haskellProjectFile = import ./nix/haskell-project.nix;
    shellModule = import ./nix/shell-module.nix;
    perSystemOutputs = import ./nix/per-system-outputs.nix;
  };
in
flake
