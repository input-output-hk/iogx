{ inputs, config, pkgs }:

rec {

  autobuild-readthedocs-site = import ./autobuild-readthedocs-site.nix
    { inherit config pkgs sphinx-toolchain; };

  build-readthedocs-site = import ./build-readthedocs-site.nix
    { inherit config pkgs sphinx-toolchain; };

  cabal-fmt = import ./cabal-fmt.nix
    { inherit pkgs; };

  combined-plutus-haddock = import ./combined-plutus-haddock.nix
    { inherit inputs pkgs; };

  nixpkgs-fmt = import ./nixpkgs-fmt.nix
    { inherit pkgs; };

  fix-cabal-fmt = import ./fix-cabal-fmt.nix
    { inherit pkgs cabal-fmt; };

  fix-png-optimization = import ./fix-png-optimization.nix
    { inherit pkgs; };

  fix-prettier = import ./fix-prettier.nix
    { inherit pkgs; };

  read-the-docs-site = import ./read-the-docs-site.nix
    { inherit config pkgs sphinx-toolchain combined-plutus-haddock; };

  scriv = import ./scriv.nix
    { inherit pkgs; };

  sphinx-markdown-tables = import ./sphinx-markdown-tables.nix
    { inherit pkgs; };

  sphinx-toolchain = import ./sphinx-toolchain.nix
    { inherit pkgs sphinxcontrib-haddock sphinxcontrib-bibtex sphinx-markdown-tables sphinxemoji; };

  sphinxcontrib-bibtex = import ./sphinxcontrib-bibtex.nix
    { inherit pkgs; };

  sphinxcontrib-haddock = import ./sphinxcontrib-haddock.nix
    { inherit inputs pkgs; };

  sphinxemoji = import ./sphinxemoji.nix
    { inherit pkgs; };

}
