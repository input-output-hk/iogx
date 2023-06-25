{ inputs, inputs', iogx-interface, iogx-config, pkgs, l, src, ... }:

{ flake }:

let 

  initial-jobset = { inherit (flake) packages checks devShells; };


  user-hydra = iogx-interface.load-hydra-jobs null; 
  

  # TODO use hasAttrByPath to validate
  addIncludedPaths = l.restrictManyAttrsByPathString user-hydra.includedPaths;


  addProfiledBuilds = jobs: 
    let 
      profiled-paths = l.flip l.concatMap iogx-config.haskellCompilers (ghc: [
        "packages.${ghc}-profiled" 
        "packages.${ghc}-xwindows-profiled"
        "apps.${ghc}-profiled" 
        "apps.${ghc}-xwindows-profiled"
        "checks.${ghc}-profiled" 
        "checks.${ghc}-xwindows-profiled"
        "devShells.${ghc}-profiled" 
        "devShells.${ghc}-xwindows-profiled"
      ]);
    in 
    if !user-hydra.includeProfiledBuilds then 
      l.deleteManyAttrsByPathString profiled-paths jobs;
    else 
      jobs;

  
  addPreCommitCheck = jobs: 
    let 
      pre-commit-check-paths = l.flip l.concatMap iogx-config.haskellCompilers (ghc: [
        "packages.${ghc}.pre-commit-check" 
      ]);
    in 
    if !user-hydra.includePreCommitCheck then 
      l.deleteManyAttrsByPathString pre-commit-check-paths jobs;
    else 
      jobs;


  # TODO use hasAttrByPath to validate
  removeExcludedPaths = l.deleteManyAttrsByPathString user-hydra.excludedPaths;


  # Hydra doesn't like these attributes hanging around in "jobsets": it thinks they're jobs!
  cleanJobs = l.filterAttrsRecursive (name: _: name != "recurseForDerivations");


  addRequiredJob = jobs:
    let
      required-job = pkgs.releaseTools.aggregate {
        name = "required";
        meta.description = "All jobs required to pass CI";
        constituents = pkgs.lib.collect pkgs.lib.isDerivation jobs;
      };
    in
    jobs // { required = required-job; };


  hydra-jobs =
    l.composeManyLeft [
      addIncludedPaths
      addProfiledBuilds
      addPreCommitCheck
      removeExcludedPaths
      cleanJobs
      addRequiredJob
    ] 
      initial-jobset;

in

hydra-jobs

