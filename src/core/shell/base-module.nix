{ inputs, inputs', iogx-config, pkgs, l, src, ... }:

{ project }:

let 

  shell = project.shell;


  haskell-toolchain = src.toolchain."haskell-toolchain-${project.meta.haskellCompiler}";


  optional-env = l.optionalAttrs (shell ? CABAL_CONFIG) {
    CABAL_CONFIG = shell.CABAL_CONFIG;
  };


  env = optional-env // {
    PKG_CONFIG_PATH = l.makeSearchPath "lib/pkgconfig" shell.buildInputs;
    NIX_GHC_LIBDIR = shell.NIX_GHC_LIBDIR;
  };


  all-packages =
    shell.buildInputs ++
    shell.nativeBuildInputs ++
    shell.stdenv.defaultNativeBuildInputs ++
    [
      shell.stdenv.cc.bintools

      src.toolchain.nixpkgs-fmt
      src.toolchain.cabal-fmt

      haskell-toolchain.haskell-language-server

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


  packages = l.filter l.isDerivation all-packages;


  scripts = {
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
    fourmolu = {
      exec = l.pkgToExec haskell-toolchain.fourmolu;
      description = "Haskell code formatter";
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
      exec = l.pkgToExec src.toolchain.scriv;
      description = "Maintain useful changelogs";
      group = "packages";
    };
    shellcheck = {
      exec = l.pkgToExec pkgs.shellcheck;
      description = "Shell script analysis tool";
      group = "packages";
    };
    hindent = {
      exec = l.pkgToExec haskell-toolchain.hindent;
      description = "Extensible Haskell pretty printer";
      group = "packages";
    };
    editorconfig-checker = {
      exec = l.pkgToExec pkgs.editorconfig-checker;
      description = "Check if your files consider your .editorconfig rules";
      group = "packages";
    };
  };


  enterShell = ''
    ${shell.shellHook}
  '';


  base-module = { inherit packages env scripts enterShell; };

in

base-module 
