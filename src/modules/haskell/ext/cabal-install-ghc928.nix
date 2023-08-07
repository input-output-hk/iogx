{ pkgs, ... }:
<<<<<<< HEAD:src/toolchain/cabal-install-ghc928.nix
let
=======

let

>>>>>>> 1013700 (Refactoring & Changes to the Interface):src/modules/haskell/ext/cabal-install-ghc928.nix
  project = pkgs.haskell-nix.hackage-project {
    name = "cabal-install";

    version = "3.8.1.0";

    compiler-nix-name = "ghc928";

    index-state = "2023-03-05T00:00:00Z";

    # The test suite depends on a nonexistent package...
    configureArgs = "--disable-tests";
  };
<<<<<<< HEAD:src/toolchain/cabal-install-ghc928.nix
in
=======

in

>>>>>>> 1013700 (Refactoring & Changes to the Interface):src/modules/haskell/ext/cabal-install-ghc928.nix
project.hsPkgs.cabal-install.components.exes.cabal
