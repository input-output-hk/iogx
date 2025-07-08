{ inputs, pkgs, lib }:

let
  cabalProject = pkgs.haskell-nix.cabalProject' (
    
    { config, pkgs, ... }:

    {
      name = "my-project";

      compiler-nix-name = lib.mkDefault "ghc966";

      src = lib.cleanSource ../.;

      flake.variants = {
        ghc966 = {}; # Alias for the default variant
        ghc8107.compiler-nix-name = "ghc8107";
        ghc984.compiler-nix-name = "ghc984";
        ghc9102.compiler-nix-name = "ghc9102";
        ghc9122.compiler-nix-name = "ghc9122";
      };

      inputMap = { "https://chap.intersectmbo.org/" = inputs.CHaP; };

      modules = [{
        packages = {};
      }];
    }
  );

in

cabalProject
