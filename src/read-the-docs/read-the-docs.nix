{ inputs, inputs', iogx-interface, pkgs, src, ... }:

let 
  
  rtd-config = iogx-interface.load-read-the-docs { inherit inputs inputs' pkgs; };


  supports-rtd = rtd-config.siteFolder != null;
  

  site = if supports-rtd then src.read-the-docs.site { inherit rtd-config; } else null;


  devshell-module = if supports-rtd then src.read-the-docs.devshell-module { inherit rtd-config; } else {};


  out = { inherit site devshell-module; };

in 

  out 
