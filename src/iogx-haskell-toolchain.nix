{ inputs, systemized-inputs, pkgs, config, base-toolchain, l }:

ghc:

with base-toolchain;

rec {

  get-haskell-tool = import ./get-haskell-tool.nix
    { inherit ghc; };

  cabal-install = get-haskell-tool "cabal-install"
    { inherit pkgs ghc; };

  fix-stylish-haskell = import ./fix-stylish-haskell.nix
    { inherit pkgs stylish-haskell; };

  haskell-language-server-project = get-haskell-tool "haskell-language-server-project"
    { inherit pkgs inputs ghc; };

  haskell-language-server = import ./haskell-language-server.nix
    { inherit haskell-language-server-project; };

  haskell-language-server-wrapper = import ./haskell-language-server-wrapper.nix
    { inherit haskell-language-server-project; };

  hlint = import ./hlint.nix
    { inherit haskell-language-server-project; };

  hie-bios = import ./hie-bios.nix
    { inherit haskell-language-server-project; };

  pre-commit-check = import ./pre-commit-check.nix
    { inherit inputs pkgs config stylish-haskell nixpkgs-fmt cabal-fmt; };

  stylish-haskell = import ./stylish-haskell.nix
    { inherit haskell-language-server-project; };

}
