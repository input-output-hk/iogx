{ pkgs, flakeopts, l, ... }:

{ hydraJobs }:

let
  blacklistDerivations = jobs:
    l.deleteManyAttrsByPathString jobs flakeopts.hydraJobs.blacklistedDerivations;

  filterProfiledHaskell = jobs:
    if flakeopts.hydraJobs.excludeProfiledHaskell then
      l.filterAttrsRecursive (name: _: !l.hasSuffix "-profiled" name) jobs
    else
      jobs;

  # TODO https://ci.zw3rk.com/build/2097394/nixlog/1
  removePlanNix = l.filterAttrsRecursive (name: _: name != "plan-nix");

  filtered-hydra-jobs = removePlanNix (filterProfiledHaskell (blacklistDerivations hydraJobs));

  # Hydra doesn't like these attributes hanging around in "jobsets": it thinks they're jobs!
  cleaned-hydra-jobs = l.filterAttrsRecursive (n: _: n != "recurseForDerivations") filtered-hydra-jobs;

  required-job = pkgs.releaseTools.aggregate {
    name = "required";
    meta.description = "All jobs required to pass CI";
    constituents = pkgs.lib.collect pkgs.lib.isDerivation cleaned-hydra-jobs;
  };

  final-hydra-jobs = cleaned-hydra-jobs // { required = required-job; };
in
final-hydra-jobs
