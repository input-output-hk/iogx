{ user-inputs, pkgs, lib, system, ... }:

# The required job is a special job that succeeds when all other hydraJobs succeed.

{ ... }:

let

  clean-jobs =
    lib.filterAttrsRecursive (name: _: name != "recurseForDerivations")
    (removeAttrs user-inputs.self.hydraJobs.${system} [ "required" ]);

  required-job = pkgs.releaseTools.aggregate {
    name = "required";
    meta.description = "All jobs required to pass CI";
    constituents = lib.collect lib.isDerivation clean-jobs;
  };

in required-job
