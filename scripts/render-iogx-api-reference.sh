set -e
nix build .#render-iogx-api-reference --show-trace "$@"
cp result doc/api.md