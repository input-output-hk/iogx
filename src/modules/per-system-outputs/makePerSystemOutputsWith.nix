{ pkgs, l, iogx-interface, inputs, inputs', __flake__, ... }:

{ extra-args ? { } }:

let

  per-system-outputs =
    let args = { inherit inputs inputs' pkgs; } // extra-args;
    in iogx-interface."per-system-outputs.nix".load args;


  mkInvalidOutputsError = field: errmsg: l.iogxError "per-system-outputs" ''
    Your nix/per-system-outputs.nix contains an invalid field: ${field}

    ${errmsg}
  '';


  validated-per-system-outputs =
    if per-system-outputs ? devShells then
      mkInvalidOutputsError "devShells" "Define your shells in nix/shell.nix instead."
    else if per-system-outputs ? hydraJobs then
      mkInvalidOutputsError "hydraJobs" "Define your CI jobset in nix/hydra-jobs.nix instead."
    else if per-system-outputs ? ciJobs then
      mkInvalidOutputsError "ciJobs" "This field has been obsoleted and replaced by hydraJobs."
    else
      per-system-outputs;


  mkCollisionError = field: { n, duplicates }: l.iogxError "per-system-outputs" ''
    Your nix/per-system-outputs.nix contains an invalid field: ${field}

    It has ${toString n} ${l.plural n "attribute"} that are reserved for IOGX: 

      ${l.concatStringsSep ", " duplicates}
  '';


  mergeOutputsOrThrow = field:
    l.mergeDisjointAttrsOrThrow
      (l.getAttrWithDefault field { } __flake__)
      (l.getAttrWithDefault field { } per-system-outputs)
      (mkCollisionError field);


  per-system-outputs' = validated-per-system-outputs;
  #  // {
  #   packages = mergeOutputsOrThrow "packages";
  #   apps = mergeOutputsOrThrow "apps";
  #   checks = mergeOutputsOrThrow "checks";
  # };

  # TODO warn on nonstandard outputs

in

per-system-outputs'



