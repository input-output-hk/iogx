{ src, pkgs, ... }:

let
  sphinxcontrib-haddock = src.modules.read-the-docs.ext.sphinxcontrib-haddock;
in

pkgs.python3.withPackages (py: [

  src.modules.read-the-docs.ext.sphinxcontrib-bibtex
  src.modules.read-the-docs.ext.sphinx-markdown-tables
  src.modules.read-the-docs.ext.sphinxemoji

  sphinxcontrib-haddock.sphinxcontrib-haddock
  sphinxcontrib-haddock.sphinxcontrib-domaintools

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
