{ pkgs, src, iogx-config, l, ... }:

let
  mkSite = ghc: { "${ghc}-readthedocs-site" = src.readthedocs.mkSite ghc; };

  default-site = { "readthedocs-site" = src.readthedocs.mkSite iogx-config.defaultHaskellCompiler; };

  all-sites = [ default-site ] ++ map mkSite iogx-config.haskellCompilers;

  aggregated-sites = l.recursiveUpdateMany all-sites;
in
aggregated-sites
