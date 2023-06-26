{ inputs, inputs', iogx-interface, iogx-config, pkgs, l, src, ... }:

{ flake }:

let 
  projects = flake.__projects__;


  per-system-outputs = iogx-interface.load-per-system-outputs { inherit inputs inputs' pkgs projects; };


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
    else if per-system-outputs ? __projects__ then 
      mkInvalidOutputsError "__projects__" "This field is reserved for IOGX."
    else 
      per-system-outputs;   


  mkCollisionError = field: { n, duplicates }: l.iogxError "per-system-outputs" ''
    Your nix/per-system-outputs.nix contains an invalid field: ${field}

    It has ${toString n} ${l.plural n "attribute"} that are reserved for IOGX: 

      ${l.concatStringsSep ", " duplicates}
  '';


  mergeOutputsOrThrow = field: 
    l.mergeDisjointAttrsOrThrow 
      flake.${field} 
      (l.getAttrWithDefault field {} per-system-outputs) 
      (mkCollisionError field);


  final-flake = validated-per-system-outputs // {
    packages = mergeOutputsOrThrow "packages";
    apps = mergeOutputsOrThrow "apps";
    checks = mergeOutputsOrThrow "checks";
    inherit (flake) __projects__ devShells;
  };

in 
  final-flake