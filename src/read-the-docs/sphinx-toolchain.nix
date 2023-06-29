{ pkgs, src, ... }:

pkgs.python3.withPackages (py: [

  src.readthedocs.sphinxcontrib-haddock.sphinxcontrib-haddock
  src.readthedocs.sphinxcontrib-haddock.sphinxcontrib-domaintools
  src.readthedocs.sphinxcontrib-bibtex
  src.readthedocs.sphinx-markdown-tables
  src.readthedocs.sphinxemoji

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
