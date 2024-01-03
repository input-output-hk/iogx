{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

mkGitRevProjectOverlay-IN:

let

  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config."mkGitRevProjectOverlay.<in>" = mkGitRevProjectOverlay-IN;
    }];
  };


  args = evaluated-modules.config."mkGitRevProjectOverlay.<in>";


  overlay = _: prev: {
    hsPkgs = prev.pkgs.pkgsHostTarget.setGitRevForPaths
      prev.pkgs.gitrev
      args.exePaths
      prev.hsPkgs;
  };

in

args.project.appendOverlays [ overlay ]
