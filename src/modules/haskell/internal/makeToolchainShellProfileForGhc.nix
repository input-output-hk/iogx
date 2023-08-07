{ src, l, ... }:

ghc: # The compiler-nix-name for which to build the toolchain

let

  shell-profile = {
    packages =
      l.attrValues (src.modules.haskell.internal.makeToolchainForGhc ghc);
  };

in

shell-profile
