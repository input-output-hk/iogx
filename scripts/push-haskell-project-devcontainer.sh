if [ -z "$1" ]; then
  echo "usage: push-haskell-project-devcontainer VERSION"
  exit 1
fi

version="$1"

set -euo pipefail

echo "Loading the docker image ..."

docker load -i "$(nix build .#haskell-project-devcontainer)"

docker tag plutus-tx-template "inputoutput/plutus-tx-template:$version"
docker tag plutus-tx-template "inputoutput/plutus-tx-template:latest"

docker push "inputoutput/plutus-tx-template:$version"
docker push "inputoutput/plutus-tx-template:latest"