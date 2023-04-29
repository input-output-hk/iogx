{ iogx, ... }:
{
  cabal-install = iogx.toolchain."cabal-install-3.6.2.0";
  fix-stylish-haskell = iogx.toolchain."fix-stylish-haskell-0.12.2.0";
  haskell-language-server = iogx.toolchain."haskell-language-server-1.3.0.0";
  haskell-language-server-wrapper = iogx.toolchain."haskell-language-server-wrapper-1.3.0.0";
  hlint = iogx.toolchain."hlint-3.2.7";
  stylish-haskell = iogx.toolchain."stylish-haskell-0.12.2.0";
  pre-commit-check = iogx.toolchain."pre-commit-check-ghc8107";
}
