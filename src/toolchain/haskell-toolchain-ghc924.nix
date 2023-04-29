{ iogx, ... }:
{
  cabal-install = iogx.toolchain."cabal-install-3.8.1.0";
  haskell-language-server = iogx.toolchain."haskell-language-server-1.9.0.0";
  haskell-language-server-wrapper = iogx.toolchain."haskell-language-server-wrapper-1.9.0.0";
}
