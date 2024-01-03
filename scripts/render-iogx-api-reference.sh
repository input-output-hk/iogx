# A simple script to render the iogx API reference to a markdown file.
# This script is available inside the iogx `nix develop` shell.
# Remember to run this script before committing changes to GitHub.
# TODO: make a git pre-commit hook that runs this.

set -e
nix build .#rendered-iogx-api-reference --show-trace "$@"
cp result doc/api.md