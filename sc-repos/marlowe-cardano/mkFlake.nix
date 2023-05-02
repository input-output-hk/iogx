{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake {
    inputs = { self = flake; };
    repoRoot = iogx-inputs.marlowe-cardano;
    shellName = "marlowe-cardano";
    haskellProjectFile = import ./__iogx__/haskell-project.nix;
    shellModule = import ./__iogx__/shell-module.nix;
    perSystemOutputs = import ./__iogx__/per-system-outputs.nix;
    flakeOutputsPrefix = "__iogx__";
  };
in
flake
