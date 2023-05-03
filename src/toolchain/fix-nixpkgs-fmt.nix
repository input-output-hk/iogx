{ pkgs, iogx, ... }:

pkgs.writeShellApplication {

  name = "fix-nixpkgs-fmt";

  text = ''
    ${iogx.toolchain.nixpkgs-fmt}/bin/nixpkgs-fmt "$REPO_ROOT"
  '';
}
