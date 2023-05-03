{ pkgs, ... }:

pkgs.writeShellApplication {

  name = "fix-prettier";

  runtimeInputs = [
    pkgs.fd
    pkgs.nodePackages.prettier
  ];

  text = ''
    fd \
      --extension html \
      --extension js \
      --extension ts \
      --extension css \
      --exec bash -c "prettier -w {}"
  '';
}
