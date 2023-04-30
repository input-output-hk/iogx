{ inputs, pkgs, flakeopts, iogx, ... }:

{ shell }:

let
  l = pkgs.lib;

  haskell-toolchain = iogx.toolchain."haskell-toolchain-${shell.ghc}";

  optional-env = l.optional (shell ? CABAL_CONFIG) {
    CABAL_CONFIG = shell.CABAL_CONFIG;
  };

  env = optional-env // {
    PKG_CONFIG_PATH = l.makeSearchPath "lib/pkgconfig" shell.buildInputs;
    NIX_GHC_LIBDIR = shell.NIX_GHC_LIBDIR;
  };

  shellPackages =
    shell.buildInputs ++
    shell.nativeBuildInputs ++
    shell.stdenv.defaultNativeBuildInputs ++
    [
      shell.stdenv.cc.bintools

      iogx.toolchain.nixpkgs-fmt
      iogx.toolchain.scriv
      iogx.toolchain.fix-cabal-fmt
      iogx.toolchain.fix-png-optimization
      iogx.toolchain.fix-prettier
      iogx.toolchain.cabal-fmt

      haskell-toolchain.cabal-install
      haskell-toolchain.fix-stylish-haskell
      haskell-toolchain.haskell-language-server
      haskell-toolchain.haskell-language-server-wrapper
      haskell-toolchain.hlint
      haskell-toolchain.stylish-haskell

      pkgs.nodePackages.prettier
      pkgs.curl
      pkgs.ghcid
      pkgs.jq
      pkgs.editorconfig-core-c
      pkgs.openssl
      pkgs.pkg-config
      pkgs.pre-commit
      pkgs.shellcheck
      pkgs.sqlite-interactive
      pkgs.yq
      pkgs.z3
      pkgs.docker-compose
      pkgs.sqitchPg
      pkgs.json2yaml
      pkgs.yaml2json
      pkgs.postgresql

      pkgs.glibcLocales
      pkgs.libsodium-vrf
      pkgs.lzma
      pkgs.openssl_3_0.dev
      pkgs.secp256k1
      pkgs.zlib
    ];
in
{
  packages = l.filter l.isDerivation shellPackages;

  enterShell = ''
    ${shell.shellHook}
    ${haskell-toolchain.pre-commit-check.shellHook}
  '';
}
