{ iogx, ... }:
{
  cabal-install = iogx.toolchain.cabal-install-ghc925;
  fix-stylish-haskell = iogx.toolchain.fix-stylish-haskell-ghc925;
  haskell-language-server = iogx.toolchain.haskell-language-server-ghc925;
  haskell-language-server-wrapper = iogx.toolchain.haskell-language-server-wrapper-ghc925;
  hlint = iogx.toolchain.hlint-ghc925;
  stylish-haskell = iogx.toolchain.stylish-haskell-ghc925;
  pre-commit-check = iogx.toolchain.pre-commit-check-ghc925;
}
