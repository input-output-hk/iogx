{ repoRoot, inputs, pkgs, lib, system }:

let

  project = repoRoot.nix.project;

in

[
  (
    # Docs for project.flake: https://github.com/input-output-hk/iogx/blob/main/doc/api.md#mkhaskellprojectoutflake
    project.flake
  )
  (lib.optionalAttrs (system == "x86_64-linux") {
    hydraJobs.devcontainer-docker-image = repoRoot.nix.devcontainer-docker-image;
    hydraJobs.push-devcontainer-docker-image = repoRoot.nix.push-devcontainer-docker-image;
  })
]
