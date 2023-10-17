{ repoRoot, inputs, pkgs, lib, system }:

[
  {
    devShells.default = repoRoot.nix.shell;
  }
]
