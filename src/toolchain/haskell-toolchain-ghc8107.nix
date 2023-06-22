{ src, pkgs, ... }:
{
  cabal-install = src.toolchain.cabal-install-ghc8107;
  haskell-language-server = src.toolchain.haskell-language-server-ghc8107;
  haskell-language-server-wrapper = src.toolchain.haskell-language-server-wrapper-ghc8107;
  hlint = src.toolchain.hlint-ghc8107;
  hindent = src.toolchain.hindent-ghc8107;
  stylish-haskell = src.toolchain.stylish-haskell-ghc8107;
  pre-commit-check = src.toolchain.pre-commit-check-ghc8107;
  fourmolu = pkgs.haskellPackages.fourmolu; # The version provided by HLS is way too old
}
