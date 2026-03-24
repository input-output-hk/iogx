{ inputs, system }:

import inputs.nixpkgs {
  inherit system;
  config = inputs.haskell-nix.config;
  overlays = [
    inputs.iohk-nix.overlays.crypto
    inputs.iohk-nix.overlays.cardano-lib
    inputs.haskell-nix.overlay
    inputs.iohk-nix.overlays.haskell-nix-crypto
    inputs.iohk-nix.overlays.haskell-nix-extra
    # Workaround for haskell.nix bootstrap.nix referencing GHC versions
    # (ghc943, ghc944) removed from nixpkgs-unstable.
    # See: https://github.com/input-output-hk/iogx/issues/125
    (final: prev: {
      haskell = prev.haskell // {
        compiler = prev.haskell.compiler // {
          ghc943 = prev.haskell.compiler.ghc948;
          ghc944 = prev.haskell.compiler.ghc948;
        };
      };
    })
  ];
}
