{ inputs, inputs', iogx-config, pkgs, l, src, iogx-interface, ... }:

let

  # marlowe:runtime-web:lib:server
  # 1.                   ghc8107.marlowe-runtime-web-lib-server
  # 2.          ghc8107-profiled.marlowe-runtime-web-lib-server
  # 3. ghc8107-mingwW64-profiled.marlowe-runtime-web-lib-server
  # 4.          ghc8107-mingwW64.marlowe-runtime-web-lib-server
  renameHaskellProjectFlakeOutputs = { flake, project }:
    let
      replaceCons = l.replaceStrings [ ":" ] [ "-" ];

      renameComponent = name: l.nameValuePair (replaceCons name);

      namespace =
        let
          ghc = project.meta.haskellCompiler;
          cross' = l.optionalString project.meta.enableCross "-mingwW64";
          profiled' = l.optionalString project.meta.enableProfiling "-profiled";
        in
        "${ghc}${cross'}${profiled'}";

      extra-packages = {
        project-roots = flake.hydraJobs.roots;
        project-plan-nix = flake.hydraJobs.plan-nix;
        project-coverage = flake.hydraJobs.coverage;
        pre-commit-check = src.core.pre-commit-check { inherit project; }; # TODO evaluated twice, retrieve from shell
      };

      renamed-flake = rec {
        devShells.${namespace} = flake.devShells.default;
        apps.${namespace} = l.mapAttrs' renameComponent flake.apps;
        checks.${namespace} = l.mapAttrs' renameComponent flake.checks;
        packages.${namespace} = l.mapAttrs' renameComponent flake.packages // extra-packages;
      };
    in
    renamed-flake;

      
  haskellProjectToFlake = project:
    let 
      mkBaseFlake = _: 
        let devShell = src.core.shell.shell { inherit project __flake__; };
        in pkgs.haskell-nix.haskellLib.mkFlake project { inherit devShell; };

      renameFlake = flake: renameHaskellProjectFlakeOutputs { inherit flake project; };

      removeLegacyDevShell = flake: removeAttrs flake [ "devShell" ];
    in  
    l.composeManyLeft [
      mkBaseFlake
      renameFlake
      removeLegacyDevShell
    ]
      project;


  addDefaultDevShell = flake:
    let 
      final-flake = l.recursiveUpdate flake { 
        devShells.default = flake.devShells."${iogx-config.defaultHaskellCompiler}";
      };
    in 
      final-flake;


  addHydraJobs = flake: 
    flake // { 
      hydraJobs = src.core.hydra-jobs { inherit flake; };
    };


  addHaskellProjects = flake: flake // { __projects = src.core.haskell-projects; };


  # At this point, flake has the __projects attr.
  addHaskellProjectsFlakes = flake: 
    let 
      flakes = l.mapAttrsToList (_: haskellProjectToFlake) flake.__projects;
    in 
      flake // l.recursiveUpdateMany flakes;


  addUserPerSystemOutputs = flake:
    let 
      projects = flake.__projects;

      per-system-outputs = iogx-interface.load-per-system-outputs { inherit inputs inputs' pkgs projects; };
      
      mkInvalidOutputsError = field: errmsg: l.iogxError "per-system-outputs" ''
        Your ./nix/per-system-outputs.nix contains an invalid field: ${field}

        ${errmsg}
      '';

      validated-per-system-outputs = 
        if per-system-outputs ? devShells then 
          mkInvalidOutputsError "devShells" "Define your shells in ./nix/shell.nix instead."
        else if per-system-outputs ? hydraJobs then 
          mkInvalidOutputsError "hydraJobs" "Define your CI jobset in ./nix/hydra-jobs.nix instead."
        else if per-system-outputs ? ciJobs then 
          mkInvalidOutputsError "ciJobs" "This field has been obsoleted and replaced by hydraJobs."
        else if per-system-outputs ? __projects then 
          mkInvalidOutputsError "__projects" "This field is reserved for IOGX."
        else 
          per-system-outputs;   

      mkCollisionError = field: { n, duplicates }: l.iogxError "per-system-outputs" ''
        Your ./nix/per-system-outputs.nix contains an invalid field: ${field}

        It contains ${toString n} ${l.plural n "attribute"} that are reserved for IOGX: 

          ${l.concatStringsSep ", " duplicates}
      '';

      checkCollisionsIn = field: 
        l.mergeDisjointAttrsOrThrow 
          flake.${field} 
          (l.getAttrWithDefault field {} per-system-outputs) 
          (mkCollisionError field);

      final-flake = validated-per-system-outputs // {
        packages = checkCollisionsIn "packages";
        apps = checkCollisionsIn "apps";
        checks = checkCollisionsIn "checks";
        inherit (flake) __projects devShells;
      };
    in 
      final-flake;


  __flake__ =
    l.composeManyLeft [
      addHaskellProjects
      addHaskellProjectsFlakes
      addDefaultDevShell
      addUserPerSystemOutputs
      addHydraJobs
    ]
      { };

in

__flake__
