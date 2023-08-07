{ src, pkgs, ... }:
{
  cabal-install = src.toolchain.cabal-install-ghc928;
  haskell-language-server = src.toolchain.haskell-language-server-ghc928;
  haskell-language-server-wrapper = src.toolchain.haskell-language-server-wrapper-ghc928;
  hlint = src.toolchain.hlint-ghc928;
  hindent = src.toolchain.hindent-ghc928;
  stylish-haskell = src.toolchain.stylish-haskell-ghc928;
  pre-commit-check = src.toolchain.pre-commit-check-ghc928;
  fourmolu = src.toolchain.fourmolu;
}
