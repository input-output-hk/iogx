{ inputs, pkgs, iogx-config, src, ... }:

let
  l = pkgs.lib;
in
{
  packages = [
    src.readthedocs.sphinx-toolchain
    pkgs.nix
    pkgs.python3
  ];

  scripts.rtd-autobuild = {
    description = "live develop read-the-docs site in ${iogx-config.readTheDocsFolder}/_build";
    text = ''
      doc="${iogx-config.readTheDocsFolder}"
      sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
    '';
  };

  scripts.rtd-build = {
    description = "build read-the-docs site in ${iogx-config.readTheDocsFolder}/_build";
    text = ''
      doc="${iogx-config.readTheDocsFolder}"
      sphinx-build -j 4 -n "$doc" "$doc/_build"
    '';
  };

  # TODO fix hardcoded .#ghc8107
  scripts.rtd-serve = {
    description = "full nix build + serve at localhost:8002 read-the-docs site";
    text = ''
      nix build .#ghc8107-readthedocs-site --out-link result
      (cd result && python -m http.server 8002)
    '';
  };

}
