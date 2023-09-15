{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

haskellProject'':

let

  utils = lib.iogx.utils;


  evaluated-modules = lib.evalModules {
    modules = [{
      options.haskellProject = lib.iogx.options.haskellProject;
      config.haskellProject = haskellProject'';
    }];
  };


  haskellProject = evaluated-modules.config.haskellProject;


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

      warnDuplicateComponentNames = duplicates: utils.iogxTrace ''
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


  iogx-overlay = cabalProject: _: # This will be called for each projectVariant as well
    let
      devShell = 
        let 
          read-the-docs-shell-profile = repoRoot.src.core.mkReadTheDocsShellProfile haskellProject.readTheDocs;
          cabal-project-shell-profile = mkCabalProjectShellProfile cabalProject;
          extra-shell-profiles = [ cabal-project-shell-profile read-the-docs-shell-profile ];
          final-shell = repoRoot.src.core.mkShell (haskellProject.shellFor cabalProject) extra-shell-profiles;
        in 
          final-shell;

      flake = pkgs.haskell-nix.haskellLib.mkFlake cabalProject { inherit devShell; };
      
      inherit (mkAliasedOutputs flake) 
        apps 
        checks 
        packages;
      
      inherit (flake) 
        hydraJobs;

      combined-haddock = repoRoot.src.core.mkCombinedHaddock cabalProject haskellProject.combinedHaddock;
      read-the-docs-site = repoRoot.src.core.mkReadTheDocsSite haskellProject.readTheDocs combined-haddock;
      pre-commit-check = devShell.pre-commit-check;

      defaultFlakeOutputs = rec {
        devShells.default = devShell;
        inherit apps checks packages;
        hydraJobs.${cabalProject.args.compiler-nix-name} = hydraJobs;
        hydraJobs.combined-haddock = combined-haddock;
        hydraJobs.read-the-docs-site = read-the-docs-site;
        hydraJobs.pre-commit-check = pre-commit-check;
      };
    in
    {
      iogx = {
        inherit 
          flake 
          apps 
          checks 
          packages 
          hydraJobs
          combined-haddock 
          read-the-docs-site
          pre-commit-check
          defaultFlakeOutputs;
      };
    };


  project' = pkgs.haskell-nix.cabalProject' haskellProject.cabalProjectArgs;


  project = project'.appendOverlays [ iogx-overlay ];

in

project
