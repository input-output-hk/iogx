{ repo, pkgs, ... }:

let
  sphinxcontrib-haddock = repo.src.ext.sphinxcontrib-haddock;
in

pkgs.python3.withPackages (py: [

  repo.src.ext.sphinxcontrib-bibtex
  repo.src.ext.sphinx-markdown-tables
  repo.src.ext.sphinxemoji

  sphinxcontrib-haddock.sphinxcontrib-haddock
  sphinxcontrib-haddock.sphinxcontrib-domaintools

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
