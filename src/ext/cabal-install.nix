{ pkgs, lib, ... }:

# Builds cabal-install using the given ghc version.

ghc:

let

  config =
    if lib.hasInfix "ghc98" ghc then
      {
        version = "3.10.3.0";
      }
    else
      {
        version = "3.10.3.0";
      };

  project = pkgs.haskell-nix.hackage-project {

    name = "cabal-install";

    version = "3.10.3.0"; #config.version;

    compiler-nix-name = ghc;

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";

    modules = [{
      packages.cabal-install.components.exes.cabal.dontStrip = false;
    }];
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
