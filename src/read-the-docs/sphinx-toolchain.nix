{ pkgs, src, ... }:

pkgs.python3.withPackages (py: [

  src.read-the-docs.sphinxcontrib-haddock.sphinxcontrib-haddock
  src.read-the-docs.sphinxcontrib-haddock.sphinxcontrib-domaintools
  src.read-the-docs.sphinxcontrib-bibtex
  src.read-the-docs.sphinx-markdown-tables
  src.read-the-docs.sphinxemoji

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
