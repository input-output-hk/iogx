{ pkgs, src, ... }:

{ readthedocs-config }:

let 
  
  # FIXME we want a local folder
  siteRoot = readthedocs-config.siteRoot; 

in 

{

  packages = [
    src.readthedocs.sphinx-toolchain
    pkgs.python3
  ];


  scripts.rtd-autobuild = {
    description = "Live develop your RTD site";
    group = "readthedocs";
    exec = ''
      doc="${siteRoot}"
      sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
    '';
  };


  scripts.rtd-build = {
    description = "Build your RTD site";
    group = "readthedocs";
    exec = ''
      doc="${siteRoot}"
      sphinx-build -j 4 -n "$doc" "$doc/_build"
    '';
  };


  scripts.rtd-serve = {
    description = "Full nix build + serve RTD site at localhost:8002";
    group = "readthedocs";
    exec = ''
      nix build .#read-the-docs-site --out-link result
      (cd result && python -m http.server 8002)
    '';
  };
}
