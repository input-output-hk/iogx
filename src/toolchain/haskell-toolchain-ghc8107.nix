{ iogx, ... }:
{
  cabal-install = iogx.toolchain.cabal-install-ghc8107;
  fix-stylish-haskell = iogx.toolchain.fix-stylish-haskell-ghc8107;
  haskell-language-server = iogx.toolchain.haskell-language-server-ghc8107;
  haskell-language-server-wrapper = iogx.toolchain.haskell-language-server-wrapper-ghc8107;
  hlint = iogx.toolchain.hlint-ghc8107;
  stylish-haskell = iogx.toolchain.stylish-haskell-ghc8107;
  pre-commit-check = iogx.toolchain.pre-commit-check-ghc8107;
}
