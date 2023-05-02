{ iogx-inputs }:

let
  flake = iogx-inputs.self.mkFlake {
    inputs = { self = flake; };
    repoRoot = iogx-inputs.quickcheck-dynamic;
    shellName = "quickcheck-dynamic";
    haskellProjectFile = import ./nix/haskell-project.nix;
  };
in
flake
