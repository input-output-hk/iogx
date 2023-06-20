{ inputs, inputs', iogx-config, pkgs, l, src, interface-files, ... }:

# TODO check collisions whenever we use // or l.recursiveUpdate or l.recursiveUpdateMany

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
        let devShell = src.core.shell.shell { inherit project; };
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


  # TODO throw error if user outputs contain hydraJobs or ciJobs or devShells?
  addUserPerSystemOutputs = flake:
    let 
      projects = flake.__projects;
      per-system-outputs = interface-files.read-per-system-outputs { inherit inputs inputs' pkgs projects; };
      final-flake = l.recursiveUpdate per-system-outputs flake; 
    in 
      final-flake;


  final-outputs =
    l.composeManyLeft [
      addHaskellProjects
      addHaskellProjectsFlakes
      addDefaultDevShell
      addUserPerSystemOutputs
      addHydraJobs
    ]
      { };

in

final-outputs
