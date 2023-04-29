{ pkgs, iogx, ... }:

pkgs.python3.withPackages (py: [

  iogx.toolchain.sphinxcontrib-haddock.sphinxcontrib-haddock
  iogx.toolchain.sphinxcontrib-haddock.sphinxcontrib-domaintools
  iogx.toolchain.sphinxcontrib-bibtex
  iogx.toolchain.sphinx-markdown-tables
  iogx.toolchain.sphinxemoji

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
