{ pkgs, ... }:

# TODO Remove this patch once the PR makes it into a hackage release.
# See https://github.com/phadej/cabal-fmt/pull/68
let

  project = pkgs.haskell-nix.hackage-project {
    name = "cabal-fmt";

    version = "0.1.7";

    compiler-nix-name = "ghc92";

    # Cabal is a lib library, so haskell.nix would normally use the one coming
    # from the compiler-nix-name (currently 3.2). However cabal-fmt depends on
    # Cabal library version 3.6, hence we add this line.
    modules = [{
      reinstallableLibGhc = true;

      packages.cabal-fmt.components.exes.cabal-fmt.dontStrip = false;
    }];
  };

in

project.hsPkgs.cabal-fmt.components.exes.cabal-fmt
