if [ -z "$1" ]; then
  echo "usage: push-haskell-project-devcontainer VERSION"
  exit 1
fi

version="$1"

set -euo pipefail

echo "Loading the docker image ..."

docker load -i "$(nix build .#haskell-project-devcontainer)"
docker inspect --type image haskell-project-env:latest
 
docker tag plutus-tx-template "ghcr.io/input-output-hk/plutus-tx-template:$version"
docker tag plutus-tx-template "ghcr.io/input-output-hk/plutus-tx-template:latest"

docker push "ghcr.io/input-output-hk:$version"
docker push "ghcr.io/input-output-hk:latest"
