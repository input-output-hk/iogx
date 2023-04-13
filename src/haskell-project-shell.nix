{ haskell-project, haskell-toolchain }:

haskell-project.shellFor {

  withHoogle = false;

  shellHook = ''
    ${haskell-toolchain.pre-commit-check.shellHook}
  '';

  buildInputs = [
    haskell-toolchain.cabal-install
    haskell-toolchain.fix-stylish-haskell
    haskell-toolchain.haskell-language-server
    haskell-toolchain.haskell-language-server-wrapper
    haskell-toolchain.hlint
    haskell-toolchain.hie-bios
    haskell-toolchain.stylish-haskell
  ];
}


