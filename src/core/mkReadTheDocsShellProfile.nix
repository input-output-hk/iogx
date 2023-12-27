{ repoRoot, pkgs, ... }:

# Return an attrset containing packages and scripts for developing a RTD site.

# The readTheDocs submodule in mkHaskellProject-IN
readTheDocs:

let

  shell-profile = {

    packages = [
      repoRoot.src.ext.sphinx-toolchain
      pkgs.python3
    ];


    scripts.develop-rtd-site = {
      description = "Develop your site live in ${readTheDocs.siteFolder}";
      group = "read-the-docs";
      exec = ''
        repo_root="$(git rev-parse --show-toplevel)"
        doc="$repo_root/${readTheDocs.siteFolder}"
        sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
      '';
    };


    scripts.build-rtd-site = {
      description = "Build your site in ${readTheDocs.siteFolder}";
      group = "read-the-docs";
      exec = ''
        repo_root="$(git rev-parse --show-toplevel)"
        doc="$repo_root/${readTheDocs.siteFolder}"
        sphinx-build -j 4 -n "$doc" "$doc/_build"
      '';
    };


    scripts.serve-rtd-site = {
      description = "Build with nix and then serve your site at localhost:8002";
      group = "read-the-docs";
      exec = ''
        nix build .#read-the-docs-site --out-link result "$@"
        (cd result && python -m http.server 8002)
      '';
    };
  };

in

if readTheDocs.enable then shell-profile else { } 


