{ inputs, systemized-inputs, pkgs, flakeopts, l, ... }:

{ flake }:

let
  blacklistJobs = jobs:
    l.deleteManyAttrsByPathString jobs flakeopts.blacklistedHydraJobs;


  filterProfiledHaskell = jobs:
    if flakeopts.excludeProfiledHaskellFromHydraJobs then
      l.filterAttrsRecursive (name: _: !l.hasSuffix "-profiled" name) jobs
    else
      jobs;


  # TODO https://ci.zw3rk.com/build/2097394/nixlog/1
  removePlanNix = l.filterAttrs (name: _: name != "plan-nix");


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


  replaceDevShells = jobs:
    let
      jobs' = { devShells = removeAttrs flake.devShells [ "default" ]; };
    in
    jobs // jobs';


  addUserPerSystemOutputs = jobs:
    let
      flake = flakeopts.perSystemOutputs
        { inherit inputs systemized-inputs flakeopts pkgs; };

      # TODO why exclude user's hydraJobs?
      jobs' = removeAttrs flake [ "ciJobs" "hydraJobs" ];
    in
    l.recursiveUpdate jobs jobs';


  removeUnwantedOutputs = jobs:
    let
      all-names = l.attrNames jobs;
      included-names = flakeopts.includedFlakeOutputsInHydraJobs;
      remove-names = l.subtractLists included-names all-names;
    in
    removeAttrs jobs remove-names;


  mkFinalJobset =
    l.composeManyLeft [
      removePlanNix
      filterProfiledHaskell
      replaceDevShells
      addUserPerSystemOutputs
      blacklistJobs
      cleanJobs
      removeUnwantedOutputs
      addRequiredJob
    ];

in

mkFinalJobset flake.hydraJobs
