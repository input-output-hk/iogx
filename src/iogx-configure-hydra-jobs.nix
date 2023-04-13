{ config, outputs, l }:

let

  base-hydra-jobs = {
    inherit (outputs) apps checks devShells packages;
  };

  extractHaskellNixHydraJobs = ghc: {
    coverage.${ghc} = outputs.hydraJobs.${ghc}.coverage;
    coverage.profiled.${ghc} = outputs.hydraJobs.profiled.${ghc}.coverage;
    plan-nix.${ghc} = outputs.hydraJobs.${ghc}.plan-nix;
    plan-nix.profiled.${ghc} = outputs.hydraJobs.profiled.${ghc}.plan-nix;
    roots.${ghc} = outputs.hydraJobs.${ghc}.roots;
    roots.profiled.${ghc} = outputs.hydraJobs.profiled.${ghc}.roots;
  };

  # These come from haskell.nix
  hydra-jobs-from-haskell-nix =
    l.recursiveUpdateMany (map extractHaskellNixHydraJobs config.haskell.compilers);

  hydra-jobs-from-outputs =
    l.recursiveUpdateMany [ base-hydra-jobs hydra-jobs-from-haskell-nix ];

  blacklistDerivations = jobs:
    l.deleteManyAttrsByPathString jobs config.hydraJobs.blacklistedDerivations;

  filterProfiledHaskell = jobs:
    if config.hydraJobs.excludeProfiledHaskell then
      l.deleteManyAttrsByPathString jobs
        [
          "apps.profiled"
          "checks.profiled"
          "coverage.profiled"
          "devShells.profiled"
          "packages.profiled"
          "plan-nix.profiled"
          "roots.profiled"
        ]
    else
      jobs;

in
filterProfiledHaskell (blacklistDerivations hydra-jobs-from-outputs) 
