{ inputs, config, system }:

let
  libsodium-vrf-overlay = import ./libsodium-vrf-overlay.nix;

  R-overlay = import ./R-overlay.nix;

  # overlays = config.overlays { inherit config inputs system; };

  iohk-nix = import inputs.iohk-nix { };
in
import inputs.nixpkgs {
  system = system;
  config = inputs.haskell-nix.config;
  overlays =
    # overlays ++
    # iohk-nix.overlays.crypto ++
    iohk-nix.overlays.iohkNix ++
    [ inputs.haskell-nix.overlay libsodium-vrf-overlay R-overlay ];
}
