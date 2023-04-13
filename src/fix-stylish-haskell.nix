{ pkgs, stylish-haskell }:

pkgs.writeShellApplication {

  name = "fix-stylish-haskell";

  runtimeInputs = [
    pkgs.fd
    stylish-haskell
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
