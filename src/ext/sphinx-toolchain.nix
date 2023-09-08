{ repoRoot, pkgs, ... }:

let
  sphinxcontrib-haddock = repoRoot.src.ext.sphinxcontrib-haddock;
in

pkgs.python3.withPackages (py: [

  repoRoot.src.ext.sphinxcontrib-bibtex
  repoRoot.src.ext.sphinx-markdown-tables
  repoRoot.src.ext.sphinxemoji

  sphinxcontrib-haddock.sphinxcontrib-haddock
  sphinxcontrib-haddock.sphinxcontrib-domaintools

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
