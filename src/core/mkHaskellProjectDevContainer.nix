# This is a vscode devcontainer that can be used with the plutus-tx-template project.
{ repoRoot, inputs, pkgs, lib, system }:

let

  devShell = lib.iogx.mkShell {
    tools.haskellCompilerVersion = "ghc963";
  };

  shellImage = pkgs.dockerTools.buildNixShellImage {
    # drv = pkgs.haskell-nix.shellFor {
    drv = pkgs.mkShell {

      shellHook = ''
        export PS1='\[\033[0;32;40m\][devcontainer]$\[\033[0m\] '
      '';

      buildInputs = devShell.buildInputs ++ devShell.nativeBuildInputs ++ devShell.propagatedBuildInputs ++ [
        # nsswitch-conf

        pkgs.coreutils
        pkgs.procps
        pkgs.gnugrep
        pkgs.gnused
        pkgs.less
        pkgs.binutils
        pkgs.pkg-config

        # add /bin/sh
        pkgs.bashInteractive

        # runtime dependencies of nix
        pkgs.cacert
        pkgs.git
        pkgs.gnutar
        pkgs.gzip
        pkgs.xz

        # for haskell binaries
        pkgs.iana-etc

        # for user management
        # pkgs.shadow linux 

        # for the vscode extension
        pkgs.gcc-unwrapped
        pkgs.findutils
        # pkgs.iproute linux

        # nice-to-have tools
        pkgs.curl
        pkgs.jq
        pkgs.which

        # haskell stuff
        pkgs.haskell-nix.compiler.ghc963
        # devShell.tools.haskell-language-server
        # devShell.tools.haskell-language-server-wrapper
        # devShell.tools.cabal-install
      ];
    };
    name = "haskell-project-devcontainer";
    tag = "latest";
    # uid = "1000";
    # gid = "1000";
    # homeDirectory = "/build";
  };

in

shellImage


