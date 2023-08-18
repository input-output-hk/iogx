{ pkgs, system, l, repoRoot, iogxRepoRoot, iogx-interface, inputs, inputs', ... }:

{ extra-args ? { }, flake }: # Can't use the __flake__ above or inf. rec.

let

  per-system-outputs =
    let args = { inherit repoRoot iogxRepoRoot inputs inputs' pkgs system; lib = l; } // extra-args;
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

    '${field}' already contains the ${toString n} ${l.plural n "attribute"} listed below.
    This could be because some cabal executables exist with these names:

      ${l.concatStringsSep ", " duplicates}
  '';


  mergeOutputsOrThrow = field:
    l.mergeDisjointAttrsOrThrow
      (l.getAttrWithDefault field { } flake)
      (l.getAttrWithDefault field { } per-system-outputs)
      (mkCollisionError field);


  flake' = validated-per-system-outputs // {
    packages = mergeOutputsOrThrow "packages";
    apps = mergeOutputsOrThrow "apps";
    checks = mergeOutputsOrThrow "checks";
    devShells = mergeOutputsOrThrow "devShells";
  };

  # TODO warn on nonstandard outputs

in

flake'



