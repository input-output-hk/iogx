{ pkgs, iogx, ... }:

pkgs.writeShellApplication {

  name = "fix-stylish-haskell";

  runtimeInputs = [
    pkgs.fd
    iogx.toolchain."stylish-haskell-0.12.2.0"
  ];

  text = ''
    if [ ! -f .stylish-haskell.yaml ]; then 
      echo ".stylish-haskell.yaml not found in the current directory, skipping"
    else 
      fd \
        --extension hs \
        --exclude 'dist-newstyle/*' \
        --exclude 'dist/*' \
        --exclude '.stack-work/*' \
        --exec bash -c "stylish-haskell -c .stylish-haskell.yaml -i {}"
    fi
  '';
}
