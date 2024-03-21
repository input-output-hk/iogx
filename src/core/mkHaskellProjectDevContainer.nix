# This is a vscode devcontainer that can be used with the plutus-tx-template project.
{ repoRoot, inputs, pkgs, lib, system }:

let

  devShell = lib.iogx.mkShell {
    tools.haskellCompilerVersion = "ghc963";
  };

  # This is an evil hack to allow us to have a docker container with a "similar" environment to
  # our haskell.nix shell without having it actually run nix develop. In particular, we need some
  # of the flags that the stdenv setup hooks set based on the build inputs, like NIX_LDFLAGS.
  # The result of this derivation is a file that can be sourced to set the variables we need.
  horrible-env-vars-hack = pkgs.runCommand "exfiltrate-env-vars"
    {
      inherit (devShell) buildInputs nativeBuildInputs propagatedBuildInputs;
    }
    ''
      set | grep -v -E '^BASHOPTS=|^BASH_VERSINFO=|^EUID=|^PPID=|^SHELLOPTS=|^UID=|^HOME=|^TEMP=|^TMP=|^TEMPDIR=|^TMPDIR=|^NIX_ENFORCE_PURITY=' >> $out
    '';

  bashrc = pkgs.writeText "bashrc" ''
    # interactive session
    if [[ $- == *i* ]]; then
      PS1='\[\033[0;32;40m\][devcontainer]$\[\033[0m\] '
    fi
    source /etc/profile.d/env.sh
  '';

  # See: https://github.com/NixOS/docker/issues/7
  nsswitch-conf = pkgs.writeTextFile {
    name = "nsswitch.conf";
    text = "hosts: dns files";
    destination = "/etc/nsswitch.conf";
  };

  nonRootUser = "plutus";
  nonRootUserId = "1000";

  # I think we should be able to use buildLayeredImage, but for some reason it
  # produces a nonfunctional image
  image = pkgs.dockerTools.buildImage {

    name = "plutus-tx-template";
    tag = "latest";

    # fromImage = someBaseImage;
    # fromImageName = null;
    # fromImageTag = "latest";

    diskSize = 4096;
    # buildVMMemorySize = 512;

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      pathsToLink = [ "/bin" ];
      paths = [
        nsswitch-conf

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
        pkgs.shadow

        # for the vscode extension
        pkgs.gcc-unwrapped
        pkgs.findutils
        pkgs.iproute

        # nice-to-have tools
        pkgs.curl
        pkgs.jq
        pkgs.which

        # haskell stuff
        pkgs.haskell-nix.compiler.ghc963
        devShell.tools.haskell-language-server
        devShell.tools.haskell-language-server-wrapper
        devShell.tools.cabal-install
      ];
    };

    runAsRoot = ''
      cd / 

      # for /usr/bin/env
      mkdir usr
      ln -s ../bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp
    
      # allow ubuntu ELF binaries to run. VSCode copies it's own.
      chmod +w lib64
      ln -s ${pkgs.glibc}/lib64/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
      ln -s ${pkgs.gcc-unwrapped.lib}/lib64/libstdc++.so.6 lib64/libstdc++.so.6
      chmod -w lib64

      # Put the environment stuff somewhere convenient
      chmod +w etc
      mkdir -p etc/profile.d
      echo 'set -o allexport' >> etc/profile.d/env.sh
      echo 'source ${horrible-env-vars-hack}' >> etc/profile.d/env.sh
      echo 'set +o allexport' >> etc/profile.d/env.sh

      # We just clobbered this, put it back
      echo 'export PATH=$PATH:/usr/bin:/bin' >> etc/profile.d/env.sh
      echo 'export NIX_BUILD_TOP=$(mktemp -d)' >> etc/profile.d/env.sh

      ${pkgs.dockerTools.shadowSetup}
      groupadd --gid ${nonRootUserId} ${nonRootUser}
      useradd --uid ${nonRootUserId} --gid ${nonRootUserId} ${nonRootUser}

      mkdir -p /home/${nonRootUser}
      cat ${bashrc} > /home/${nonRootUser}/.bashrc

      # Because we map in the `./.cabal` folder from the users home directory,
      # (see: https://github.com/input-output-hk/plutus-starter/blob/main/.devcontainer/devcontainer.json)
      # and because docker won't let us map a volume not as root
      # (see: https://github.com/moby/moby/issues/2259 link), we have to make the
      # folder first and chown it ...
      mkdir -p /home/${nonRootUser}/.cabal/packages

      chown -R ${nonRootUser}:${nonRootUser} /home/${nonRootUser}
    '';

    config = {
      Cmd = [ "/bin/bash" ];
      User = nonRootUser;
      Env = [
        "BASH_ENV=/etc/profile.d/env.sh"
        "GIT_SSL_CAINFO=/etc/ssl/certs/ca-bundle.crt"
        "LD_LIBRARY_PATH=${pkgs.gcc-unwrapped.lib}/lib64"
        "PAGER=less"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "USER=${nonRootUser}"
        "LANG=C.UTF-8"
      ];
    };
  };

  image' = image // { meta = pkgs.nix.meta // image.meta; };


  shellImage = pkgs.dockerTools.buildNixShellImage {
    drv = pkgs.mkShell {
      shellHook = ''
        #whoami
        #mkdir -p /build/.cabal/packages
        #chown 1000:1000 -R /build/.cabal
      '';
      buildInputs = [
        nsswitch-conf

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
        devShell.tools.haskell-language-server
        devShell.tools.haskell-language-server-wrapper
        devShell.tools.cabal-install
      ];
    };
    name = "haskell-project-env";
    tag = "latest";
    uid = "1000";
    gid = "1000";
    # homeDirectory = "/home/plutus";

    # command = ''
    #   mkdir -p /build/.cabal/packages
    #   chown -R 1000:1000 /build/.cabal/packages
    # '';
    #   #groupadd --gid 1001 plutus
    #   #useradd --uid 1001 --gid 1001 plutus
    #   mkdir -p /build/.cabal/packages
    #   chown -R plutus:plutus /home/plutus

    #   # if [[ $- == *i* ]]; then
    #   PS1='\[\033[0;32;40m\][devcontainer]$\[\033[0m\] '
    #   #fi
    #   # Because we map in the `./.cabal` folder from the users home directory,
    #   # (see: https://github.com/input-output-hk/plutus-starter/blob/main/.devcontainer/devcontainer.json)
    #   # and because docker won't let us map a volume not as root
    #   # (see: https://github.com/moby/moby/issues/2259 link), we have to make the
    #   # folder first and chown it ...
    # '';
  };

in

shellImage
# image'


