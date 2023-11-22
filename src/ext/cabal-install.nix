{ pkgs, lib, ... }:

ghc:

let

  config =
    if lib.hasInfix "ghc98" ghc then
      {
        # TODO remove this hack when a new version of cabal (> 3.10.1.0) 
        # is released which can be built with ghc98. 
        compiler-nix-name = "ghc96";
      }
    else
      {
        compiler-nix-name = ghc;
      };

  project = pkgs.haskell-nix.hackage-project {

    name = "cabal-install";

    version = "3.10.1.0";

    compiler-nix-name = config.compiler-nix-name;

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";

    modules = [{
      packages.cabal-install.components.exes.cabal.dontStrip = false;
    }];
  };

in

project.hsPkgs.cabal-install.components.exes.cabal
