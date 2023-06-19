{ pkgs, src, ... }:

pkgs.writeShellApplication {

  name = "fix-nixpkgs-fmt";

  runtimeInputs = [
    src.toolchain.nixpkgs-fmt
  ];

  text = ''
    nixpkgs-fmt . 
  '';
}
