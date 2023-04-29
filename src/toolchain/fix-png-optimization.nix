{ pkgs, ... }:

pkgs.writeShellApplication {

  name = "fix-png-optimization";

  runtimeInputs = [
    pkgs.fd
    pkgs.optipng
  ];

  text = ''
    fd --extension png --exec "optipng" {}
  '';
}
