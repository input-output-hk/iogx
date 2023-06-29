{ pkgs, src, l, user-repo-root, ... }:

{ rtd-config }:

{

  packages = [
    src.read-the-docs.sphinx-toolchain
    pkgs.python3
  ];


  scripts.autobuild-rtd-site = {
    description = "Live develop your site in ${rtd-config.siteFolder}";
    group = "read-the-docs";
    exec = ''
      doc="${rtd-config.siteFolder}"
      sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
    '';
  };


  scripts.build-rtd-site = {
    description = "Build your site in ${rtd-config.siteFolder}";
    group = "read-the-docs";
    exec = ''
      doc="${rtd-config.siteFolder}"
      sphinx-build -j 4 -n "$doc" "$doc/_build"
    '';
  };


  scripts.serve-rtd-site = {
    description = "Build with nix and then serve your site at localhost:8002";
    group = "read-the-docs";
    exec = ''
      nix build .#read-the-docs-site --out-link result
      (cd result && python -m http.server 8002)
    '';
  };
}
