{ src, ... }:

ghc: # The compiler-nix-name for which to build the toolchain

let
  hls = src.modules.haskell.ext."haskell-language-server-project-${ghc}";
in

{
  cabal-fmt = src.modules.haskell.ext.cabal-fmt;
  cabal-install = src.modules.haskell.ext."cabal-install-${ghc}";
  fourmolu = src.modules.haskell.ext.fourmolu;
  hlint = hls.hsPkgs.hlint.components.exes.hlint;
  stylish-haskell = hls.hsPkgs.stylish-haskell.components.exes.stylish-haskell;
  haskell-language-server = hls.hsPkgs.haskell-language-server.components.exes.haskell-language-server;
  haskell-language-server-wrapper = hls.hsPkgs.haskell-language-server.components.exes.haskell-language-server-wrapper;
}
