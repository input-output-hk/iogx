{ iogx, ... }:
{
  cabal-install = iogx.toolchain.cabal-install-ghc927;
  fix-stylish-haskell = iogx.toolchain.fix-stylish-haskell-ghc927;
  haskell-language-server = iogx.toolchain.haskell-language-server-ghc927;
  haskell-language-server-wrapper = iogx.toolchain.haskell-language-server-wrapper-ghc927;
  hlint = iogx.toolchain.hlint-ghc927;
  stylish-haskell = iogx.toolchain.stylish-haskell-ghc927;
  pre-commit-check = iogx.toolchain.pre-commit-check-ghc927;
}
