{ inputs, inputs', iogx-config, iogx-interface, pkgs, l, src, ... }:

{ flake }:

let

  user-hydra = iogx-interface.load-hydra-jobs { inherit inputs inputs' pkgs; };


  # TODO use hasAttrByPath to validate
  addIncludedPaths = l.restrictManyAttrsByPathString user-hydra.includedPaths;


  # TODO use hasAttrByPath to validate
  removeExcludedPaths = l.deleteManyAttrsByPathString user-hydra.excludedPaths;


  # TODO check collisions
  addExtraJobs = l.recursiveUpdate user-hydra.extraJobs;


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
    # l.composeManyLeft [
    #   # addIncludedPaths
    #   # removeExcludedPaths
    #   # addExtraJobs
    #   # cleanJobs
    #   # addRequiredJob
    # ] 
      # flake; # TODO use inputs.self instead of flake?
      # { packages.entrypoints.testnet-dev.node = pkgs.stdenv.mkDerivation { name="asd"; }; }; # TODO use inputs.self instead of flake?
      { what = pkgs.stdenv.mkDerivation { name="asd"; }; }; # TODO use inputs.self instead of flake?

in

hydra-jobs

