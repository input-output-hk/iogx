{ inputs, inputs', pkgs, src, ... }:

{ flake }:

let 

  rtd-config = iogx-interface.load-read-the-docs { inherit inputs inputs' pkgs; };


  supports-rtd = readthedoc-config.siteRoot != null;
  

  site = if supports-rtd then src.read-the-docs.site { inherit readthedoc-config; } else null;


  devshell-profile = if supports-rtd then src.read-the-docs.devshell-profile { inherit readthedocs-config; } else {};


  out = { inherit site devshell-profile; };

in 

  out 
