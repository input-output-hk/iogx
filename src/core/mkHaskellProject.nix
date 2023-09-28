{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

haskellProject':

let

  utils = lib.iogx.utils;


  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config.mkHaskellProject-IN = haskellProject';
    }];
  };


  haskellProject = evaluated-modules.config.mkHaskellProject-IN;


  mkAliasedOutputs = flake:
    let
      makeAliasesForGroup = group:
        let
          mkPair = name: lib.nameValuePair (makeAliasForComp name);
          isExe = lib.strings.hasInfix ":exe";
          isTest = lib.strings.hasInfix ":test";
          isBench = lib.strings.hasInfix ":bench";
          isRunnable = name: isExe name || isTest name || isBench name;
          runnables = lib.filterAttrs (name: _: isRunnable name) group;
        in
        lib.mapAttrs' mkPair runnables;

      makeAliasForComp = name: lib.last (lib.splitString ":" name);

      findDuplicateComps = group:
        let names = lib.attrNames (makeAliasesForGroup group);
        in utils.findDuplicates names;

      makeAliasesForGroupIfNoDuplicates = group:
        let duplicates = findDuplicateComps group; in
        if lib.length duplicates == 0 then
          makeAliasesForGroup group
        else
          warnDuplicateComponentNames duplicates { };

      warnDuplicateComponentNames = duplicates: utils.iogxThrow ''
        There are multiple components with the same name across your cabal files:

          ${lib.concatStringsSep " " duplicates}

        Therefore I cannot create unique flake outputs for those.
        Rename the components across your cabal files so that they are unique.'';

      outputs = {
        apps = makeAliasesForGroupIfNoDuplicates flake.apps;
        checks = makeAliasesForGroupIfNoDuplicates flake.checks;
        packages = makeAliasesForGroupIfNoDuplicates flake.packages;
      };
    in
    outputs;


  mkProjectShellProfile = project:
    let
      devshell = pkgs.haskell-nix.haskellLib.devshellFor project.shell;
      packages = devshell.packages;
      env = lib.listToAttrs devshell.env;
    in
    { inherit packages env; };

  
  mkProjectDevShell = project: 
    let
      read-the-docs-profile = repoRoot.src.core.mkReadTheDocsShellProfile haskellProject.readTheDocs;
      cabal-project-profile = mkProjectShellProfile project;
      shell-profiles = [ cabal-project-profile read-the-docs-profile ];

      tools-args = { tools.haskellCompilerVersion = project.args.compiler-nix-name; };
      project-args = haskellProject.shellArgsForProjectVariant project;
      shell-args = lib.recursiveUpdate tools-args project-args;
    in 
      repoRoot.src.core.mkShellWith shell-args shell-profiles;


  mkProjectVariantOutputs = project:
    let 
      devShell = mkProjectDevShell project; 
      devShells.default = devShell;

      originalFlake = pkgs.haskell-nix.haskellLib.mkFlake project { inherit devShell; };

      inherit (mkAliasedOutputs originalFlake)
        apps
        checks
        packages;

      inherit (originalFlake) hydraJobs;

      combined-haddock = repoRoot.src.core.mkCombinedHaddock project haskellProject.combinedHaddock;
      read-the-docs-site = repoRoot.src.core.mkReadTheDocsSite haskellProject.readTheDocs combined-haddock;
      pre-commit-check = devShell.pre-commit-check;
    in 
    {
      cabalProject = project;
      inherit apps checks packages devShells devShell hydraJobs;
      inherit combined-haddock read-the-docs-site pre-commit-check;
    };


  mkCrossVariantOutputs = project: 
    let 
      flake = pkgs.haskell-nix.haskellLib.mkFlake project {};
      hydraJobs = removeAttrs flake.hydraJobs [ "devShell" "devShells" ];
    in 
    { inherit hydraJobs; };


  iogx-project =
    let 
      base = haskellProject.haskellDotNixProject;

      mkProjectVariant = project: 
        ( mkProjectVariantOutputs project ) // 
        { cross = utils.mapAttrValues mkCrossVariantOutputs project.projectCross; };
      
      project = 
        ( mkProjectVariant base ) //
        { variants = utils.mapAttrValues mkProjectVariant base.projectVariants; }; 
      
      extra-packages = { 
        inherit (project) combined-haddock read-the-docs-site pre-commit-check; 
      };

      flake = {
        inherit (project) devShell devShells apps checks cabalProject;
        
        hydraJobs = # TODO profiled
          project.hydraJobs // 
          extra-packages // 
          utils.mapAttrValues (project: project.hydraJobs) project.variants //
          { required = repoRoot.src.core.mkHydraRequiredJob {}; } //
          lib.optionalAttrs 
            (system == "x86_64-linux" && haskellProject.crossCompileMingwW64Supported)
            { mingwW64 = project.cross.mingwW64.hydraJobs; }; 

        packages = project.packages // extra-packages;
      };
    in 
      project // { inherit flake; };

in

iogx-project
