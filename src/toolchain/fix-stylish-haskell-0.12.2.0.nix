{ pkgs, iogx, ... }:

pkgs.writeShellApplication {

  name = "fix-stylish-haskell";

  runtimeInputs = [
    pkgs.fd
    iogx.toolchain."stylish-haskell-0.12.2.0"
  ];

  text = ''
    fd \
      --extension hs \
      --exclude 'dist-newstyle/*' \
      --exclude 'dist/*' \
      --exclude '.stack-work/*' \
      --exec bash -c "stylish-haskell -i {}"
  '';
}
