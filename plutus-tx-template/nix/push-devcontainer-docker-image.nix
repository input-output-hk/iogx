{ repoRoot, inputs, pkgs, lib, system }:

let
  dockerImage = repoRoot.nix.devcontainer-docker-image;

  imageRef = dockerImage.imageName + ":" + dockerImage.imageTag;

  dockerHubRepoName = "inputoutput/plutus-tx-template";
in
pkgs.writeScript "push-devcontainer-docker-image" ''
  #!${pkgs.runtimeShell}
  set -euo pipefail

  echo "Loading the docker image ..."
  docker load -i ${dockerImage}

  tag="''${BUILDKITE_TAG:-}"
  echo "Git tag: ''${tag}."

  # Pick out only the version component of a tag like:
  # "plutus-tx-template/v1.0" -> "v1.0"
  # "v1.0" -> "v1.0"
  version="$(echo $tag | sed -e 's/.*[\/]//')"

  # Construct a tag to push up to dockerHub
  docker tag "${imageRef}" "${dockerHubRepoName}:''${version}"
  docker tag "${imageRef}" "${dockerHubRepoName}:latest"

  docker push "${dockerHubRepoName}:''${version}"
  docker push "${dockerHubRepoName}:latest"
''
