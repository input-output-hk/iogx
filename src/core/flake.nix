{ inputs, inputs', iogx-config, pkgs, l, src, iogx-interface, ... }:

let

  # marlowe:runtime-web:lib:server
  # 1.                   ghc8107.marlowe-runtime-web-lib-server
  # 2.          ghc8107-profiled.marlowe-runtime-web-lib-server
  # 3. ghc8107-xwindows-profiled.marlowe-runtime-web-lib-server
  # 4.          ghc8107-xwindows.marlowe-runtime-web-lib-server
  renameHaskellProjectFlakeOutputs = { flake, project }:
    let
      replaceCons = l.replaceStrings [ ":" ] [ "-" ];

      renameComponent = name: l.nameValuePair (replaceCons name);

      namespace =
        let
          ghc = project.meta.haskellCompiler;
          cross' = l.optionalString project.meta.enableCross "-windows";
          profiled' = l.optionalString project.meta.enableProfiling "-profiled";
        in
        "${ghc}${cross'}${profiled'}";

      extra-packages = {
        project-roots = flake.hydraJobs.roots;
        project-plan-nix = flake.hydraJobs.plan-nix;
        project-coverage = flake.hydraJobs.coverage;
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


  # This adds the following flake outputs:
  #   packages.$ghc.pre-commit-check
  # For each $ghc in iogx-config.haskellCompilers.
  addPreCommitChecks = {}: 
    let 
      mkValue = ghc: src.core.pre-commit-check { haskellCompiler = ghc; };
      mkPair = ghc: { packages.${ghc}.pre-commit-check = mkValue ghc; };
      pre-commit-checks = l.recursiveUpdateMany (map mkPair iogx-config.haskellCompilers);
      final-flake = pre-commit-checks;
    in 
      final-flake;


  # This adds the following flake outputs:
  #   __projects__.{$ghc,$ghc-profiled,$ghc-xwindows,$ghc-xwindows-profiled}
  # For each $ghc in iogx-config.haskellCompilers.
  addHaskellProjects = flake: 
    flake // { __projects__ = src.core.haskell-projects; };


  # This adds the following flake outputs:
  #   {packages,apps,checks,devShells}.{$ghc,$ghc-profiled,$ghc-xwindows,$ghc-xwindows-profiled}.$comp
  # For each $ghc in iogx-config.haskellCompilers, and for each $comp in all cabal packages.
  addHaskellProjectsFlakes = flake: 
    let 
      project-flakes = l.mapAttrsToList (_: haskellProjectToFlake) flake.__projects__;
      projects-flake = l.recursiveUpdateMany project-flakes;
      final-flake = l.recursiveUpdate flake projects-flake;
    in 
      final-flake;


  # This adds the following flake outputs:
  #   devShells.default 
  addDefaultDevShell = flake:
    let 
      final-flake = l.recursiveUpdate flake { 
        devShells.default = flake.devShells."${iogx-config.defaultHaskellCompiler}";
      };
    in 
      final-flake;


  # This adds the flake outputs defined by the user in ./nix/per-system-outputs.nix
  addPerSystemOutputs = flake: src.core.per-system-outputs { inherit flake; };


  # This adds the following flake outputs:
  #   hydraJobs
  addHydraJobs = flake: flake // { hydraJobs = src.core.hydra-jobs { inherit flake; }; };

  
  __flake__ =
    l.composeManyLeft [
      addPreCommitChecks
      addHaskellProjects
      addHaskellProjectsFlakes
      addDefaultDevShell
      addPerSystemOutputs
      addHydraJobs
    ]
      { };

in

removeAttrs __flake__ ["apps"] 
