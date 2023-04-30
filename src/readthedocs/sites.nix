{ pkgs, iogx, flakeopts, l, ... }:

let
  mkSite = ghc: { "${ghc}-readthedocs-site" = iogx.readthedocs.mkSite ghc; };

  default-site = { "readthedocs-site" = iogx.readthedocs.mkSite flakeopts.defaultHaskellCompiler; };

  all-sites = [ default-site ] ++ map mkSite flakeopts.haskellCompilers;

  aggregated-sites = l.recursiveUpdateMany all-sites;
in
aggregated-sites
