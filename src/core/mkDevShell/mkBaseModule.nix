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
      iogx.toolchain.cabal-fmt

      iogx.haskell-toolchain.haskell-language-sever

      pkgs.nodePackages.prettier
      pkgs.curl
      pkgs.ghcid
      pkgs.jq
      pkgs.fd
      pkgs.openssl
      pkgs.pkg-config
      pkgs.pre-commit
      pkgs.yq
      pkgs.z3
      pkgs.docker-compose
      pkgs.json2yaml
      pkgs.yaml2json
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
      exec = l.pkgToExec iogx.toolchain.fix-cabal-fmt;
      description = "Format all cabal files";
      group = "formatters";
    };
    fix-png-optimization = {
      exec = l.pkgToExec iogx.toolchain.fix-png-optimization;
      description = "Optimize all png files";
      group = "formatters";
    };
    fix-prettier = {
      exec = l.pkgToExec iogx.toolchain.fix-prettier;
      description = "Format all js, ts, html and css files";
      group = "formatters";
    };
    fix-stylish-haskell = {
      exec = l.pkgToExec haskell-toolchain.fix-stylish-haskell;
      description = "Format all haskell files";
      group = "formatters";
    };
    fix-nixpkgs-fmt = {
      exec = l.pkgToExec iogx.toolchain.fix-nixpkgs-fmt;
      description = "Format all nix files";
      group = "formatters";
    };

    cabal = {
      exec = l.pkgToExec haskell-toolchain.cabal-install;
      description = "The command-line interface for Cabal and Hackage";
      group = "packages";
    };
    hlint = {
      exec = l.pkgToExec haskell-toolchain.hlint;
      description = "Haskell source code suggestions";
      group = "packages";
    };
    stylish-haskell = {
      exec = l.pkgToExec haskell-toolchain.stylish-haskell;
      description = "Haskell code prettifier";
      group = "packages";
    };
    haskell-language-server-wrapper = {
      exec = l.pkgToExec haskell-toolchain.haskell-language-server-wrapper;
      description = "LSP server for GHC";
      group = "packages";
    };
    scriv = {
      exec = l.pkgToExec iogx.toolchain.scriv;
      description = "Maintain useful changelogs";
      group = "packages";
    };
    shellcheck = {
      exec = l.pkgToExec pkgs.shellcheck;
      description = "Shell script analysis tool";
      group = "packages";
    };
  };

  enterShell = ''
    ${shell.shellHook}
    ${haskell-toolchain.pre-commit-check.shellHook}
  '';
}
