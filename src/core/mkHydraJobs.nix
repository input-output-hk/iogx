{ inputs, systemized-inputs, pkgs, iogx, flakeopts, l, ... }:

{ flake }:

let
  # Remove custom derivations by attr path.
  # TODO move this one layer up so that we can select which system to blacklist.
  blacklistJobs = jobs:
    l.deleteManyAttrsByPathString jobs flakeopts.blacklistedHydraJobs;


  # Generally we don't want to build the profiled haskell stuff in hydra, unless
  # explicitely required.
  removeProfiledHaskell = jobs:
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


  # jobs (= hydraJobs) at this stage has the old shells that come with 
  # haskell.nix:mkFlake. We replace them with our powered-up shells, making sure
  # to remove the redundant `default` and the legacy `devShell`.
  replaceDevShells = jobs:
    let
      jobs' = { devShells = removeAttrs flake.devShells [ "default" ]; };
      removeLegacyShell = l.flip removeAttrs [ "devShell" ];
    in
    # removeLegacyShell jobs // jobs';
    jobs // jobs';


  # We want this in CI.
  addPreCommitCheck = jobs:
    if flakeopts.enableHydraPreCommitCheck then
      let check = iogx.toolchain."pre-commit-check-${flakeopts.defaultHaskellCompiler}";
      in l.recursiveUpdate jobs { checks.pre-commit-check = check; }
    else
      jobs;


  # We want to build the read-the-docs sites in CI.
  addReadTheDocsPackages = jobs:
    if flakeopts.includeReadTheDocsSite then
      l.recursiveUpdate jobs { packages.readthedocs = flake.packages.readthedocs; }
    else
      jobs;


  # TODO how to add user's outputs to hydraJobs?
  # TODO check collisions
  addUserPerSystemOutputs = jobs: jobs;


  mkFinalJobset =
    l.composeManyLeft [
      # First remove the broken plan-nix
      removePlanNix
      # Then replace the "dummy" devShells with the real ones
      replaceDevShells
      # Then remove the profiled haskell artifacts, if needed
      removeProfiledHaskell
      # Then add the pre-commit-check
      addPreCommitCheck
      # Then the read-the-docs stuff, if needed
      addReadTheDocsPackages
      # Then add the user stuff
      addUserPerSystemOutputs
      # Finally remove unwanted stuff
      blacklistJobs
      # Make everything happy
      cleanJobs
      # Add the final required job
      addRequiredJob
    ];

in

# The given flake has been fully populated with the IOGX outputs, this includes 
  # readthedocs stuff (in packages).
  # The flake also contains the outputs as defined by the user, if any.
  # hydraJobs at this point comes from haskell.nix:mkFlake, and only contains the
  # haskell stuff: { packages, checks, devShells, roots, coverage, plan-nix }, but 
  # devShells must be replaced with out agumented shells, and the other outputs 
  # must still be populated with other stuff.
mkFinalJobset flake.hydraJobs

