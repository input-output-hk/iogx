{ inputs, inputs', iogx-config, pkgs, l, src, iogx-interface, ... }:

let

  # marlowe:runtime-web:lib:server
  # 1.          ghc8107-marlowe-runtime-web-lib-server
  # 2. ghc8107-profiled-marlowe-runtime-web-lib-server
  # 3. ghc8107-xwindows-marlowe-runtime-web-lib-server
  renameHaskellProjectFlakeOutputs = { flake, project }:
    let
      replaceCons = l.replaceStrings [ ":" ] [ "-" ];

      mkPair = name: l.nameValuePair (renameComponent name);

      renameComponent = name:
        let
          ghc = "-${project.meta.haskellCompiler}";
          name' = replaceCons name;
          cross' = l.optionalString project.meta.enableCross "-xwindows";
          profiled' = l.optionalString project.meta.enableProfiling "-profiled";
        in
        "${name'}${ghc}${cross'}${profiled'}";

      extra-packages = {
        project-roots = flake.hydraJobs.roots;
        project-plan-nix = flake.hydraJobs.plan-nix;
        project-coverage = flake.hydraJobs.coverage;
      };

      renamed-flake = rec {
        devShells.${renameComponent "default"} = flake.devShells.default;
        apps = l.mapAttrs' mkPair flake.apps;
        checks = l.mapAttrs' mkPair flake.checks;
        packages = l.mapAttrs' mkPair (flake.packages // extra-packages);
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

      fixupCrossProject = flake: 
        if project.meta.enableCross then # We don't want devShells nor apps
          { inherit (flake) packages checks; } 
        else 
        flake; 
    in  
    l.composeManyLeft [
      mkBaseFlake
      renameFlake
      removeLegacyDevShell
      fixupCrossProject
    ]
      project;


  # This adds the following flake outputs:
  #   packages.$ghc-pre-commit-check
  # For each $ghc in iogx-config.haskellCompilers.
  addPreCommitChecks = {}: 
    let 
      mkValue = ghc: src.core.pre-commit-check { haskellCompiler = ghc; };
      mkPair = ghc: { packages."pre-commit-check-${ghc}" = mkValue ghc; };
      pre-commit-checks = l.recursiveUpdateMany (map mkPair iogx-config.haskellCompilers);
      final-flake = pre-commit-checks;
    in 
      final-flake;


  # This adds the following flake outputs:
  #   __projects__.{$ghc,$ghc-profiled,$ghc-xwindows}
  # For each $ghc in iogx-config.haskellCompilers.
  addHaskellProjects = flake: 
    flake // { __projects__ = src.core.haskell-projects; };


  # This adds the following flake outputs:
  #   {packages,apps,checks,devShells}.{$ghc,$ghc-profiled,$ghc-xwindows}.$comp
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
  #   devShells.profiled 
  addDefaultDevShells = flake:
    # if flake ? devShells then # Could be the xwindows flake
      l.recursiveUpdate flake { 
        devShells.default = flake.devShells."default-${iogx-config.defaultHaskellCompiler}";
        devShells.profiled = flake.devShells."default-${iogx-config.defaultHaskellCompiler}-profiled";
      };
    # else 
    #   flake;


  # This adds the flake outputs defined by the user in ./nix/per-system-outputs.nix
  addPerSystemOutputs = flake: src.core.per-system-outputs { inherit flake; };


  # This adds the following flake outputs:
  #   hydraJobs
  addHydraJobs = flake: flake // { hydraJobs = src.core.hydra-jobs { inherit flake; }; };

  
  # This adds the following flake outputs:
  #   packages.read-the-docs-site
  addReadTheDocsSite = flake: 
    if src.read-the-docs.read-the-docs.site == null then 
      flake 
    else 
      l.recursiveUpdate flake { packages.read-the-docs-site = src.read-the-docs.read-the-docs.site; };


  __flake__ =
    l.composeManyLeft [
      addPreCommitChecks
      addReadTheDocsSite
      addHaskellProjects
      addHaskellProjectsFlakes
      addDefaultDevShells
      addPerSystemOutputs
      addHydraJobs
    ]
      { };

in

__flake__
