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
          exes = lib.filterAttrs (name: _: lib.strings.hasInfix ":exe:" name) group;
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


  iogx-overlay = _: cabalProject: # This will be called for each projectVariant as well
    let
      combined-haddock = repoRoot.src.core.mkCombinedHaddock cabalProject haskellProject.combinedHaddock;
      read-the-docs-site = repoRoot.src.core.mkReadTheDocsSite haskellProject.readTheDocs combined-haddock;
      read-the-docs-shell-profile = repoRoot.src.core.mkReadTheDocsShellProfile haskellProject.readTheDocs;
      cabal-project-shell-profile = mkCabalProjectShellProfile cabalProject;
      extra-shell-profiles = [ cabal-project-shell-profile read-the-docs-shell-profile ];
      shell = repoRoot.src.core.mkShell (haskellProject.shellFor cabalProject) extra-shell-profiles;
      devShell = shell.devShell;
      pre-commit-check = shell.pre-commit-check;
      flake = pkgs.haskell-nix.haskellLib.mkFlake cabalProject { inherit devShell; };
      extra-packages = { inherit pre-commit-check read-the-docs-site combined-haddock; };
      aliased-outputs = mkAliasedOutputs flake;
    in
    {
      iogx = {
        pre-commit-check = pre-commit-check;
        read-the-docs-site = read-the-docs-site;
        combined-haddock = combined-haddock;
        # flake = flake;
        # outputs = {
        devShell = devShell;
        apps = aliased-outputs.apps;
        packages = aliased-outputs.packages;
        checks = aliased-outputs.checks;
        hydraJobs = flake.hydraJobs;
        # };
      };
    };


  cabalProjectArgs = {
    src =
      utils.getAttrWithDefault
        "src"
        user-inputs.self
        haskellProject.cabalProjectArgs;

    inputMap =
      utils.getAttrWithDefault
        "inputMap"
        { "https://input-output-hk.github.io/cardano-haskell-packages" = iogx-inputs.CHaP; }
        haskellProject.cabalProjectArgs;
  };


  project' = pkgs.haskell-nix.cabalProject' cabalProjectArgs;


  project = project'.appendOverlays [ iogx-overlay ];

in

project
