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
      makeAliasesForGroupExes = group:
        let
          mkPair = name: lib.nameValuePair (makeAliasForExe name);
          isExe = lib.strings.hasInfix ":exe";
          isTest = lib.strings.hasInfix ":test";
          exes = lib.filterAttrs (name: _: isExe name || isTest name) group;
        in
        lib.mapAttrs' mkPair exes;

      makeAliasForExe = name: lib.last (lib.splitString ":" name);

      findDuplicateExes = group:
        let names = lib.attrNames (makeAliasesForGroupExes group);
        in utils.findDuplicates names;

      makeAliasesForGroupExesIfNoDuplicates = group:
        let duplicates = findDuplicateExes group; in
        if lib.length duplicates == 0 then
          makeAliasesForGroupExes group
        else
          warnDuplicateComponentNames duplicates { };

      warnDuplicateComponentNames = duplicates: utils.iogxThrow ''
        There are multiple executables with the same name across your cabal files:

          ${lib.concatStringsSep " " duplicates}

        Therefore I cannot create flake output aliases for your executables.
        Rename the executables across your cabal files so that they are unique.'';

      outputs = {
        apps = makeAliasesForGroupExesIfNoDuplicates flake.apps;
        checks = makeAliasesForGroupExesIfNoDuplicates flake.checks;
        packages = makeAliasesForGroupExesIfNoDuplicates flake.packages;
      };
    in
    outputs;


  mkCabalProjectShellProfile = cabalProject:
    let
      devshell = pkgs.haskell-nix.haskellLib.devshellFor cabalProject.shell;
      packages = devshell.packages;
      env = lib.listToAttrs devshell.env;
    in
    { inherit packages env; };


  iogx-overlay = cabalProject: _: # This will be called for each projectVariant 
    let
      shell-profiles =
        let
          read-the-docs-profile = repoRoot.src.core.mkReadTheDocsShellProfile haskellProject.readTheDocs;
          cabal-project-profile = mkCabalProjectShellProfile cabalProject;
        in
        [ cabal-project-profile read-the-docs-profile ];

      shell-args =
        let
          tools-args = { tools.haskellCompiler = cabalProject.args.compiler-nix-name; };
          project-args = haskellProject.shellArgsForProjectVariant cabalProject;
        in
        lib.recursiveUpdate tools-args project-args;

      devShell = repoRoot.src.core.mkShellWith shell-args shell-profiles;
      devShells.default = devShell;

      flake = pkgs.haskell-nix.haskellLib.mkFlake cabalProject { inherit devShell; };

      inherit (mkAliasedOutputs flake)
        apps
        checks
        packages;

      inherit (flake) hydraJobs;

      hydraJobsNoDevShell = removeAttrs hydraJobs [ "devShells" "devShell" ];

      combined-haddock = repoRoot.src.core.mkCombinedHaddock cabalProject haskellProject.combinedHaddock;
      read-the-docs-site = repoRoot.src.core.mkReadTheDocsSite haskellProject.readTheDocs combined-haddock;
      pre-commit-check = devShell.pre-commit-check;

      defaultFlakeOutputs = lib.recursiveUpdate
        {
          inherit devShell devShells apps checks packages hydraJobs;
        }
        {
          packages = { inherit combined-haddock read-the-docs-site pre-commit-check; };
          hydraJobs = { inherit combined-haddock read-the-docs-site pre-commit-check; };
        };

      iogx-attrset = {
        inherit
          apps# Cabal executables component names
          checks# Cabal testsuites component names
          packages# Cabal executables component names
          devShells# Contains devShells.default == augmented devShell
          devShell# The augmented devShell
          hydraJobs# Contains apps, checks, packages and devShells
          hydraJobsNoDevShell# Original flake, equals to hydraJobs minus the augmented shell
          combined-haddock
          read-the-docs-site
          pre-commit-check
          defaultFlakeOutputs;
      };

    in
    {
      iogx = iogx-attrset;
    };


  cabalProject' = pkgs.haskell-nix.cabalProject' haskellProject.cabalProjectArgs;


  cabalProject = cabalProject'.appendOverlays [ iogx-overlay ];


  # project =
  #   let 
  #     mkOutputs = variant: iogx-overlay variant null;
  #     mkCrossVariant = variant: mkCrossVariant
  #     mkVariant = variant: mkOutputs variant // { cabalProject = variant; };
  #   in
  #   mkVariant cabalProject // {
  #     variants = utils.mapAttrValues mkVariant cabalProject.projectVariants;
  #     cross = utils.mapAttrValues mkCrossVariant cabalProject.projectCross;
  #   };

in

cabalProject
