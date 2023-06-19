{ inputs, inputs', iogx-config, pkgs, l, src, ... }:

{ flake }:

let

  default-jobs = { inherit (flake) packages devShells checks; };


  # TODO make hydraJobsFile schema and validate
  user-jobs = 
    if iogx-config.hydraJobsFile != null then
      import iogx-config.hydraJobsFile { inherit inputs inputs' pkgs flake; }
    else
      default-jobs;


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
      cleanJobs
      addRequiredJob
    ] 
      user-jobs;

in

hydra-jobs

