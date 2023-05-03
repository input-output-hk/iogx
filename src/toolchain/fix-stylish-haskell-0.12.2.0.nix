{ pkgs, iogx, ... }:

pkgs.writeShellApplication {

  name = "fix-stylish-haskell";

  runtimeInputs = [
    pkgs.fd
    iogx.toolchain."stylish-haskell-0.12.2.0"
  ];

  text = ''
    PWD="$REPO_ROOT" fd \
      --extension hs \
      --exclude 'dist-newstyle/*' \
      --exclude 'dist/*' \
      --exclude '.stack-work/*' \
      --exec bash -c "stylish-haskell -i {}"
  '';
}
