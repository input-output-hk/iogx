{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

# The project config provided by the user.
mkHaskellProject-IN:

let

  utils = lib.iogx.utils;


  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config."mkHaskellProject.<in>" = mkHaskellProject-IN;
    }];
  };


  haskellProject = evaluated-modules.config."mkHaskellProject.<in>";


  readTheDocs = lib.recursiveUpdate haskellProject.readTheDocs {

    sphinxToolchain =
      if haskellProject.readTheDocs.sphinxToolchain == null
      then repoRoot.src.ext.sphinx-toolchain
      else haskellProject.readTheDocs.sphinxToolchain;
  };


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
          errorDuplicateComponentNames duplicates { };

      errorDuplicateComponentNames = duplicates: utils.iogxThrow ''
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
      read-the-docs-profile = repoRoot.src.core.mkReadTheDocsShellProfile readTheDocs;
      cabal-project-profile = mkProjectShellProfile project;
      shell-profiles = [ cabal-project-profile read-the-docs-profile ];

      tools-args = { tools.haskellCompilerVersion = project.args.compiler-nix-name; };
      project-args = haskellProject.shellArgs project;
      shell-args = lib.recursiveUpdate tools-args project-args;
    in
    repoRoot.src.core.mkShellWith shell-args shell-profiles;


  mkProjectDevShell2 = project:
    let
      read-the-docs-profile = repoRoot.src.core.mkReadTheDocsShellProfile readTheDocs;
      tools-args = { tools.haskellCompilerVersion = project.args.compiler-nix-name; };
      project-args = haskellProject.shellArgs project;
      shell-args = lib.recursiveUpdate tools-args project-args;
      iogx-shell = repoRoot.src.core.mkShellWith shell-args [ read-the-docs-profile ];
      final-shell = project.shell.overrideAttrs (attrs: attrs // {
        buildInputs = attrs.buildInputs ++ iogx-shell.buildInputs;
        shellHook = "${attrs.shellHook}\n${iogx-shell.shellHook}";
      });
    in
    final-shell // { inherit (iogx-shell) pre-commit-check tools; };


  mkProjectVariantOutputs = project:
    let
      # Replace mkProjectDevShell2 with mkProjectDevShell when this is merged:
      # https://github.com/input-output-hk/haskell.nix/pull/2163
      # Or keep mkProjectDevShell2 forever since it seems to be working fine.
      devShell = mkProjectDevShell2 project;
      devShells.default = devShell;

      originalFlake = pkgs.haskell-nix.haskellLib.mkFlake project { inherit devShell; };

      inherit (mkAliasedOutputs originalFlake)
        apps
        checks
        packages;

      inherit (originalFlake) hydraJobs;

      combined-haddock = repoRoot.src.core.mkCombinedHaddock project haskellProject.combinedHaddock;
      read-the-docs-site = repoRoot.src.core.mkReadTheDocsSite readTheDocs combined-haddock;
      pre-commit-check = devShell.pre-commit-check;
    in
    {
      cabalProject = project;
      inherit apps checks packages devShells devShell hydraJobs;
      inherit combined-haddock read-the-docs-site pre-commit-check;
    };


  mkCrossVariantOutputs = project:
    let
      flake = pkgs.haskell-nix.haskellLib.mkFlake project { };
      hydraJobs = removeAttrs flake.hydraJobs [ "devShell" "devShells" ];
    in
    {
      cabalProject = project;
      inherit hydraJobs;
    };


  mkDefaultFlake = project:
    let
      extra-packages = {
        combined-haddock = project.combined-haddock;
        read-the-docs-site = project.read-the-docs-site;
        pre-commit-check = project.pre-commit-check;
      };

      mingwW64-jobs = lib.optionalAttrs
        (system == "x86_64-linux" && haskellProject.includeMingwW64HydraJobs)
        { mingwW64 = project.cross.mingwW64.hydraJobs; };

      variants-jobs =
        let all = utils.mapAttrValues (project: project.hydraJobs) project.variants;
        in if haskellProject.includeProfiledHydraJobs then all else removeAttrs all [ "profiled" ];

      required-job = { required = repoRoot.src.core.mkHydraRequiredJob { }; };
    in
    {
      devShell = project.devShell;
      devShells = project.devShells;
      apps = project.apps;
      checks = project.checks;
      cabalProject = project.cabalProject;

      packages = project.packages // extra-packages;

      hydraJobs =
        required-job //
        project.hydraJobs //
        extra-packages //
        variants-jobs //
        mingwW64-jobs;
    };


  iogx-project =
    let
      base = haskellProject.cabalProject;

      mkProjectVariant = project:
        (mkProjectVariantOutputs project) //
        { cross = utils.mapAttrValues mkCrossVariantOutputs project.projectCross; };

      # { cabalProject, cross, variants
      # , combined-haddock, read-the-docs-site pre-commit-check
      # , packages/checks/apps/devShells/hydraJobs }
      project =
        (mkProjectVariant base) //
        { variants = utils.mapAttrValues mkProjectVariant base.projectVariants; };

      flake = mkDefaultFlake project;
    in
    project // { inherit flake; };

in

iogx-project
