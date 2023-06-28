{ src, ... }:

{ flake }:

let 

  readthedocs-config = iogx-interface.load-read-the-docs null;


  site = src.read-the-docs.site { inherit readthedoc-config; };


  devshell-profile = src.read-the-docs.devshell-profile { inherit readthedocs-config; };


  final-flake' = l.recursiveUpdate flake {
    packages.read-the-docs-site = site;
    hydraJobs.packages.read-the-docs-site = site;
    __iogx__.devshellProfiles.read-the-docs = devshell-profile;
  };


  final-flake = if readthedoc-config.siteRoot == null then {} else final-flake';

in 

  final-flake
