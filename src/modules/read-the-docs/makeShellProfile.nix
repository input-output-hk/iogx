{ src, pkgs, repoRoot, iogxRepoRoot, iogx-interface, inputs, inputs', l, system, ... }:

let

  read-the-docs = iogx-interface."read-the-docs.nix".load {
    inherit iogxRepoRoot repoRoot inputs inputs' pkgs system;
    lib = l;
  };

  shell-profile = {

    packages = [
      src.modules.read-the-docs.ext.sphinx-toolchain
      pkgs.python3
    ];


    scripts.develop-rtd-site = {
      description = "Develop your site live in ${read-the-docs.siteFolder}";
      group = "read-the-docs";
      exec = ''
        repo_root="$(git rev-parse --show-toplevel)"
        doc="$repo_root/${read-the-docs.siteFolder}"
        sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
      '';
    };


    scripts.build-rtd-site = {
      description = "Build your site in ${read-the-docs.siteFolder}";
      group = "read-the-docs";
      exec = ''
        repo_root="$(git rev-parse --show-toplevel)"
        doc="$repo_root/${read-the-docs.siteFolder}"
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

if read-the-docs.siteFolder == null then { } else shell-profile 


