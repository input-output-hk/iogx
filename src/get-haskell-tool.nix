{ ghc }:

let
  versions = {

    ghc8107 = {
      cabal-install = "3.6.2.0";
      haskell-language-server-project = "1.3.0.0";
      hlint = "3.2.7";
      stylish-haskell = "0.12.2.0";
    };

    ghc924 = {
      cabal-install = "3.8.1.0";
      haskell-language-server-project = "1.9.0.0";
      hlint = "TODO";
      stylish-haskell = "TODO";
    };
  };

  get-haskell-tool = name:
    import (./. + "/${name}-" + versions.${ghc}.${name} + ".nix");

in
get-haskell-tool
