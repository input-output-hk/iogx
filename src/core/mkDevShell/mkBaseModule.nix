{ inputs, pkgs, flakeopts, iogx, l, ... }:

{ shell }:

let
  haskell-toolchain = iogx.toolchain."haskell-toolchain-${shell.ghc}";

  optional-env = l.optionalAttrs (shell ? CABAL_CONFIG) {
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
      iogx.toolchain.cabal-fmt

      haskell-toolchain.cabal-install
      haskell-toolchain.haskell-language-server
      haskell-toolchain.haskell-language-server-wrapper
      haskell-toolchain.hlint
      haskell-toolchain.stylish-haskell

      pkgs.nodePackages.prettier
      pkgs.curl
      pkgs.ghcid
      pkgs.jq
      pkgs.fd
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

  inherit env;

  scripts = {
    fix-cabal-fmt = {
      exec = "${iogx.toolchain.fix-cabal-fmt}/bin/fix-cabal-fmt";
      description = "format all .cabal files in the current directory";
      group = "formatters";
    };
    fix-png-optimization = {
      exec = "${iogx.toolchain.fix-png-optimization}/bin/fix-png-optimization";
      description = "optimize all .png files in the current directory";
      group = "formatters";
    };
    fix-prettier = {
      exec = "${iogx.toolchain.fix-prettier}/bin/fix-prettier";
      description = "format all .js .ts .html .css files in the current directory";
      group = "formatters";
    };
    fix-stylish-haskell = {
      exec = "${haskell-toolchain.fix-stylish-haskell}/bin/fix-stylish-haskell";
      description = "format all .hs files in the current directory";
      group = "formatters";
    };
    fix-nixpkgs-fmt = {
      exec = "${iogx.toolchain.fix-nixpkgs-fmt}/bin/fix-nixpkgs-fmt";
      description = "format all .nix files in the current directory";
      group = "formatters";
    };
  };

  enterShell = ''
    ${shell.shellHook}
    ${haskell-toolchain.pre-commit-check.shellHook}
  '';
}
