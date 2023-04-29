{ pkgs, ... }@devx:

pkgs.writeShellApplication {

  name = "serve-readthedocs-site";

  runtimeInputs = [
    pkgs.nix
    pkgs.python3
  ];

  text = ''
    nix build .#read-the-docs-site --out-link result
    (cd result && python -m http.server 8002)
  '';
}
