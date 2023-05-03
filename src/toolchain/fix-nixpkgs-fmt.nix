{ pkgs, iogx, ... }:

pkgs.writeShellApplication {

  name = "fix-nixpkgs-fmt";

  runtimeInputs = [
    iogx.toolchain.nixpkgs-fmt
  ];

  text = ''
    nixpkgs-fmt . 
  '';
}
