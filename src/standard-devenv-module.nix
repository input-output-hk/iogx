{ pkgs, haskell-project-shell, base-toolchain }:

let
  l = pkgs.lib;

  shell = haskell-project-shell;

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

      base-toolchain.sphinx-toolchain
      base-toolchain.nixpkgs-fmt
      base-toolchain.scriv
      base-toolchain.fix-cabal-fmt
      base-toolchain.fix-png-optimization
      base-toolchain.fix-prettier
      base-toolchain.cabal-fmt

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

    export PS1="\n\[\033[1;32m\][nix develop:\w]\$\[\033[0m\] "
  '';
}
