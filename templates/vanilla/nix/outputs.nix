{ repoRoot, inputs, pkgs, lib, system }:

[{
  devShells.default = repoRoot.nix.shell;

  hydraJobs.devShells.default = inputs.self.devShells.default;
}]
