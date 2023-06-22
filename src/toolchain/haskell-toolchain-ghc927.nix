{ src, pkgs, ... }:
{
  cabal-install = src.toolchain.cabal-install-ghc927;
  haskell-language-server = src.toolchain.haskell-language-server-ghc927;
  haskell-language-server-wrapper = src.toolchain.haskell-language-server-wrapper-ghc927;
  hlint = src.toolchain.hlint-ghc927;
  hindent = src.toolchain.hindent-ghc927;
  stylish-haskell = src.toolchain.stylish-haskell-ghc927;
  pre-commit-check = src.toolchain.pre-commit-check-ghc927;
  fourmolu = pkgs.haskellPackages.fourmolu; # The version provided by HLS is way too old
}
