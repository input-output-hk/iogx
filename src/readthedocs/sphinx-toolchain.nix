{ pkgs, iogx, ... }:

pkgs.python3.withPackages (py: [

  iogx.readthedocs.sphinxcontrib-haddock.sphinxcontrib-haddock
  iogx.readthedocs.sphinxcontrib-haddock.sphinxcontrib-domaintools
  iogx.readthedocs.sphinxcontrib-bibtex
  iogx.readthedocs.sphinx-markdown-tables
  iogx.readthedocs.sphinxemoji

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
