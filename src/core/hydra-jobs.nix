{ inputs, inputs', iogx-interface, iogx-config, pkgs, l, src, ... }:

{ flake }:

let 

  initial-jobset = { inherit (flake) packages checks devShells; };


  user-hydra = iogx-interface.load-hydra-jobs null; 
  

  # TODO use hasAttrByPath to validate
  addIncludedPaths = 
    l.recursiveUpdate 
      (l.restrictManyAttrsByPathString user-hydra.includedPaths flake);


  addProfiledBuilds = jobs: 
    let filterProfiled = l.filterAttrs (name: _: !l.hasSuffix "-profiled" name); in 
    if !user-hydra.includeProfiledBuilds then 
      {
        packages = filterProfiled jobs.packages;
        checks = filterProfiled jobs.checks;
        devShells = filterProfiled jobs.devShells;
      }
    else 
      jobs;

  
  addPreCommitChecks = jobs: 
    let 
      pre-commit-check-paths = l.flip l.concatMap iogx-config.haskellCompilers (ghc: [
        "packages.pre-commit-check-${ghc}" 
      ]);
    in 
    if !user-hydra.includePreCommitCheck then 
      l.deleteManyAttrsByPathString pre-commit-check-paths jobs
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
      addPreCommitChecks
      removeExcludedPaths
      cleanJobs
      addRequiredJob
    ] 
      initial-jobset;


  is-supported-system = l.elem pkgs.stdenv.system ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];


  final-hydra-jobs = l.optionalAttrs is-supported-system hydra-jobs;

in

final-hydra-jobs

