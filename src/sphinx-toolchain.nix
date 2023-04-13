{ pkgs, sphinxcontrib-haddock, sphinxcontrib-bibtex, sphinx-markdown-tables, sphinxemoji }:

pkgs.python3.withPackages (py: [

  sphinxcontrib-haddock.sphinxcontrib-haddock
  sphinxcontrib-haddock.sphinxcontrib-domaintools
  sphinxcontrib-bibtex
  sphinx-markdown-tables
  sphinxemoji

  py.sphinxcontrib_plantuml
  py.sphinx-autobuild
  py.sphinx
  py.sphinx_rtd_theme
  py.recommonmark
])
