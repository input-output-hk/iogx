{ iogx-inputs, system }:

let
  libsodium-vrf-overlay = import ./libsodium-vrf-overlay.nix;
  R-overlay = import ./R-overlay.nix;
  iohk-nix = import iogx-inputs.iohk-nix { };
in
import iogx-inputs.nixpkgs {
  inherit system;
  config = iogx-inputs.haskell-nix.config;
  overlays =
    iohk-nix.overlays.iohkNix ++
    [
      iogx-inputs.haskell-nix.overlay
      libsodium-vrf-overlay
      R-overlay
    ];
}
