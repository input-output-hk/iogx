{ src, iogx-inputs, nix, iogx-interface, user-repo-root, inputs, inputs', pkgs, l, system, ... }:

let

  haskell = iogx-interface."haskell.nix".load
    { inherit nix inputs inputs' pkgs l system; };


  shell-profile = {

    packages = [
      src.modules.haskell.ext.scriv
    ];


    scripts.assemble-changelog = {
      description = "Assembles the changelog for PACKAGE at VERSION";
      group = "changelog";
      exec = ''
        usage () {
          echo "assemble-changelog PACKAGE VERSION"
          echo "  Assembles the changelog for PACKAGE at VERSION"
        }

        if [ "$#" == "0" ]; then
          usage
          exit 1
        fi

        PACKAGE=$1
        VERSION=$2

        echo "Assembling changelog for $PACKAGE-$VERSION"
        pushd $PACKAGE > /dev/null
        scriv collect --version "$VERSION"
        popd > /dev/null
      '';
    };


    scripts.prepare-release = {
      description = "Prepares to release PACKAGEs at VERSION";
      group = "changelog";
      exec = ''
        usage () {
          echo "prepare-release VERSION [PACKAGE...]"
          echo "  Prepares to release PACKAGEs at VERSION. If no PACKAGEs are provided,"
          echo "  prepares to release the default packages."
        }

        if [ "$#" == "0" ]; then
          usage
          exit 1
        fi

        set -euo pipefail

        VERSION=$1

        shift

        default_packages=(${l.concatStringsSep " " haskell.defaultChangelogPackages})

        release_packages=( "$@" )

        if [ ''${#release_packages[@]} -eq 0 ]; then
          release_packages+=( "''${default_packages[@]}" )
        fi

        echo "Preparing release for ''${release_packages[*]}"
        echo ""
        echo "Updating versions ..."
        for package in "''${release_packages[@]}"; do
          update-version "$package" "$VERSION"
        done

        echo ""
        echo "Assembling changelogs ..."
        for package in "''${release_packages[@]}"; do
          assemble-changelog "$package" "$VERSION"
        done
      '';
    };


    scripts.update-version = {
      description = "Updates the version for PACKAGE to VERSION";
      group = "changelog";
      exec = ''
        usage () {
          echo "update-version PACKAGE VERSION"
          echo "  Updates the version for PACKAGE to VERSION, and updates bounds"
          echo "  on that package in other cabal files."
        }

        if [ "$#" == "0" ]; then
          usage
          exit 1
        fi

        set -euo pipefail

        PACKAGE=$1
        VERSION=$2

        IFS='.' read -r -a components <<< "$VERSION"

        major_version="''${components[0]}.''${components[1]}"

        echo "Updating version of $PACKAGE to $VERSION"
        # update package version in cabal file for package
        sed -i "s/\(^version:\s*\).*/\1$VERSION/" "./$PACKAGE/$PACKAGE.cabal"

        # update version bounds in all cabal files
        # It looks for patterns like the following:
        #
        # - ", plutus-core"
        # - ", plutus-core:uplc"
        # - ", plutus-core ^>=1.0"
        # - ", plutus-core:{plutus-core, plutus-core-testlib}  ^>=1.0"
        #
        # and updates the version bounds to "^>={major version}"
        echo "Updating version bounds on $PACKAGE to '^>=$major_version'"

        repo_root="$(git rev-parse --show-toplevel)"
        find "$repo_root" -name "*.cabal" -exec sed -i "s/\(, $PACKAGE[^^]*\).*/\1 ^>=$major_version/" {} \;
      '';
    };
  };

in

shell-profile
