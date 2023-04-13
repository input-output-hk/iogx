{ pkgs, cabal-fmt }:

pkgs.writeShellApplication {

  name = "fix-cabal-fmt";

  runtimeInputs = [
    pkgs.fd
    cabal-fmt
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
