{ iogx-inputs, system }:

let
  libsodium-vrf-overlay = import ./libsodium-vrf-overlay.nix;
  R-overlay = import ./R-overlay.nix;
  inherit (iogx-inputs) iohk-nix;
in
import iogx-inputs.nixpkgs {
  inherit system;
  config = iogx-inputs.haskell-nix.config;
  overlays =
    [
      iohk-nix.overlays.crypto
      iogx-inputs.haskell-nix.overlay
      iohk-nix.overlays.haskell-nix-crypto
      iohk-nix.overlays.haskell-nix-extra
      libsodium-vrf-overlay
      R-overlay
    ];
}
