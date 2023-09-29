{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

args: 

let 

  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config.mkGitRevProjectOverlay-IN = args;
    }];
  };


  args = evaluated-modules.config.mkGitRevProjectOverlay-IN;


  overlay = _: prev: {
    hsPkgs = prev.pkgs.pkgsBuildHost.setGitRevForPaths 
      prev.pkgs.gitrev 
      exe-paths 
      prev.hsPkgs;
  };

in 

  args.project.appendOverlays [overlay]