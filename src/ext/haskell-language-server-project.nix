{ lib, pkgs, ... }:

ghc:

let

  config =
    if lib.hasInfix "ghc810" ghc then
      {
        rev = "855a88238279b795634fa6144a4c0e8acc7e9644"; # 1.8.0.0
        sha256 = "sha256-El5wZDn0br/My7cxstRzUyO7VUf1q5V44T55NEQONnI=";
        cabalProjectLocal = "constraints: stylish-haskell==0.13.0.0, hlint==3.2.8";
      }
    else if lib.hasInfix "ghc92" ghc then
      {
        rev = "1916b5782d9f3204d25a1d8f94da4cfd83ae2607"; # 1.9.0.0
        sha256 = "sha256-j3XRQTWa7jsVlimaxFZNnlE9IzWII9Prj1/+otks5FQ=";
        cabalProjectLocal = "constraints: stylish-haskell==0.14.2.0, hlint==3.4.1";
      }
    else if lib.hasInfix "ghc96" ghc then
      {
        rev = "2.4.0.0";
        sha256 = "sha256-VOMf5+kyOeOmfXTHlv4LNFJuDGa7G3pDnOxtzYR40IU=";
        cabalProjectLocal = "constraints: stylish-haskell==0.14.5.0, hlint==3.6.1";
        configureArgs = "--disable-benchmarks";
      }
    else if lib.hasInfix "ghc98" ghc then
      {
        rev = "2.4.0.0";
        sha256 = "sha256-VOMf5+kyOeOmfXTHlv4LNFJuDGa7G3pDnOxtzYR40IU=";
        cabalProjectLocal = "constraints: stylish-haskell==0.14.5.0, hlint==3.6.1";
      }
    else
      {
        rev = "2.4.0.0";
        sha256 = "sha256-VOMf5+kyOeOmfXTHlv4LNFJuDGa7G3pDnOxtzYR40IU=";
        cabalProjectLocal = "constraints: stylish-haskell==0.14.5.0, hlint==3.6.1";
      };

in

pkgs.haskell-nix.cabalProject' {

  # See https://github.com/haskell/haskell-language-server/issues/411.
  # We want to use stylish-haskell, hlint, and implicit-hie as standalone tools
  # *and* through HLS. But we need to have consistent versions in both cases,
  # otherwise e.g. you could format the code in HLS and then have the CI
  # complain that it's wrong
  #
  # The solution we use here is to:
  # a) Where we care (mostly just formatters), constrain the versions of
  #    tools which HLS uses explicitly
  # b) Pull out the tools themselves from the HLS project so we can use
  #    them elsewhere
  cabalProjectLocal = config.cabalProjectLocal or "";

  configureArgs = config.configureArgs or "";

  src = pkgs.fetchFromGitHub {
    owner = "haskell";
    repo = "haskell-language-server";
    inherit (config) rev sha256;
  };

  compiler-nix-name = ghc;

  sha256map = {
    "https://github.com/pepeiborra/ekg-json"."7a0af7a8fd38045fd15fb13445bdcc7085325460" = "sha256-fVwKxGgM0S4Kv/4egVAAiAjV7QB5PBqMVMCfsv7otIQ="; # editorconfig-checker-disable-line
  };

  modules = [{
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005
    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;

    dontStrip = false;
  }];
}
