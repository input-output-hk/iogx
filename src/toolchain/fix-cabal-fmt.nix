{ pkgs, src, ... }:

pkgs.writeShellApplication {

  name = "fix-cabal-fmt";

  runtimeInputs = [
    pkgs.fd
    src.toolchain.cabal-fmt
  ];

  text = ''
    fd \
      --extension cabal \
      --exclude 'dist-newstyle/*' \
      --exclude 'dist/*' \
      --exclude '.stack-work/*' \
      --exec bash -c "cabal-fmt --inplace {}"
  '';
}
