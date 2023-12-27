{ repoRoot, ... }:

# Create an actual nix devShell with a bunch of tools and utilities.

# The shell config provided by the user.
mkShell-IN:

repoRoot.src.core.mkShellWith mkShell-IN [ ]
