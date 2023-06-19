{ inputs, inputs', iogx-config, pkgs, l, src, ... }:

{ flake }:

let

  
  default-spec = { 
    excludedPaths = [];
    extraJobs = {};
  };


  # TODO make hydraJobsFile schema and validate
  user-spec = 
    if iogx-config.hydraJobsFile != null then
      import iogx-config.hydraJobsFile { inherit inputs inputs' pkgs flake; }
    else
      default-spec;


  # TODO use hasAttrByPath to validate
  removeExcludedPaths = jobs: l.deleteManyAttrsByPathString jobs user-spec.excludedPaths;


  # TODO check collisions
  addExtraJobs = jobs: l.recursiveUpdate jobs user-spec.extraJobs;


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
      removeExcludedPaths
      addExtraJobs
      cleanJobs
      addRequiredJob
    ] 
      flake;

in

hydra-jobs

