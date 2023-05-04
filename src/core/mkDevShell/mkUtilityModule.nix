{ inputs, pkgs, flakeopts, iogx, l, ... }:

{ flake, core-modules }:

let
  filterDisabledScripts =
    l.filterAttrs (_: { enabled ? true, ... }: enabled);


  extractScriptNames =
    l.attrNames;


  extractScriptDescriptions =
    l.mapAttrsToList (_: l.getAttrWithDefault "description" "");


  getAndFilterDisabledScripts = mod:
    filterDisabledScripts (l.getAttrWithDefault "scripts" { } mod);


  # { group1 = { name1 = { exec1, group1, description1 } }}
  partitionScriptsByGroup = scripts:
    let
      getGroup = script: l.getAttrWithDefault "group" "ungrouped" script.value;
      nameValToScript = script: { "${script.name}" = script.value; };
      groupToScripts = _: namevals: l.recursiveUpdateMany (map nameValToScript namevals);
      pairs = l.mapAttrsToList l.nameValuePair scripts;
      groups = l.groupBy getGroup pairs;
      partitioned = l.mapAttrs groupToScripts groups;
    in
    partitioned;


  all-packages =
    l.concatMap (l.getAttrWithDefault "packages" [ ]) core-modules;


  all-scripts =
    l.recursiveUpdateMany (map getAndFilterDisabledScripts core-modules);


  all-envs =
    let
      getEnv = l.getAttrWithDefault "env" { };
      merged-env = l.recursiveUpdateMany (map getEnv core-modules);
      final-env = removeAttrs merged-env [ "NIX_GHC_LIBDIR" "PKG_CONFIG_PATH" ];
    in
    final-env;


  flake-prefix =
    if flakeopts.flakeOutputsPrefix == ""
    then ""
    else "${flakeopts.flakeOutputsPrefix}.";


  # TODO this does not take into account the 
  formatFlakeOutputs = group: command:
    if group == "devShells" then
      let
        fromGhc = ghc: l.concatStringsSep "\n" [
          "nix develop .#${flake-prefix}${ghc}-default"
          "nix develop .#${flake-prefix}${ghc}-default-profiled"
        ];

        default =
          if flake-prefix == ""
          then "nix develop"
          else "nix develop .#${flake-prefix}default";

        all-shells = [ default ] ++ map fromGhc flakeopts.haskellCompilers;
      in
      l.concatStringsSep "\n" all-shells
    else
      let fromName = name: _: "nix ${command} .#${flake-prefix}${name}";
        # NOTE: at this point the flakeOutputsPrefix has not been added to the 
        # flake, that's why we can do flake.${group} and not 
        # flake.${group}.formatFlakeOutputs
      in l.concatStringsSep "\n" (l.mapAttrsToList fromName flake.${group});


  formatted-hydra-jobs =
    let
      # TODO take into account
      # excludeProfiledHaskellFromHydraJobs 
      # blacklistedHydraJobs 
      # enableHydraPreCommitCheck 

      formatSimple = system:
        let nix-build = "nix build .#hydraJobs.${system}.";
        in name: "${nix-build}${flake-prefix}${name}";

      formatGroup = system: group:
        let
          nix-build = "nix build .#hydraJobs.${system}.";
          formatOne = name: _: "${nix-build}${flake-prefix}${group}.${name}";
          strings = l.mapAttrsToList formatOne flake.hydraJobs.${group};
        in
        l.concatStringsSep "\n" strings;

      formatSystem = system:
        let
          content = l.concatStringsSep "\n" [
            (formatGroup system "packages")
            (formatGroup system "checks")
            (formatGroup system "devShells")
            (formatSimple system "pre-commit-check")
            (formatSimple system "roots")
            (formatSimple system "coverage")
            (formatSimple system "plan-nix")
            (formatSimple system "required")
          ];
        in
        ''
          ${l.ansiColor system "yellow" "bold"}

          ${content}
        '';
    in
    l.concatStringsSep "\n" (map formatSystem flakeopts.systems);


  list-hydra-jobs = {
    group = "iogx";
    description = "list everything that will be built by CI";
    exec = ''
      echo
      printf "${formatted-hydra-jobs}"
      echo
    '';
  };


  formatted-haskell-outputs = l.concatStringsSep "\n\n" [
    (l.ansiColor "Haskell Packages" "yellow" "bold")
    (formatFlakeOutputs "packages" "build")
    (l.ansiColor "Haskell Apps" "yellow" "bold")
    (formatFlakeOutputs "apps" "run")
    (l.ansiColor "Development Shells" "yellow" "bold")
    (formatFlakeOutputs "devShells" "develop")
  ];


  list-haskell-outputs = {
    group = "iogx";
    description = "list the haskell outputs buildable by nix";
    exec = ''
      echo
      printf "${formatted-haskell-outputs}"
      echo
    '';
  };


  menu-content =
    let
      extra-scripts = {
        inherit menu print-env list-haskell-outputs list-hydra-jobs;
      };

      groups = partitionScriptsByGroup (all-scripts // extra-scripts);

      formatGroup = group: scripts:
        let
          bolden = name: l.ansiColor name "white" "bold";

          list = l.prettyTwoColumnsLayout {
            indent = "  ";
            gap-width = 2;
            max-width = 120;
            lefts = map bolden (extractScriptNames scripts);
            rights = extractScriptDescriptions scripts;
          };
        in
        ''
          printf " ${l.ansiColor group "yellow" "bold"}\n"
          printf "${list}\n"
          echo
        '';

      content = l.concatStringsSep "\n" (l.mapAttrsToList formatGroup groups);
    in
    content;


  print-menu-content = ''
    echo
    echo
    printf "${l.ansiColor flakeopts.shellName "red" "bold"} development shell\n"
    echo 
    ${menu-content}
  '';


  menu = {
    group = "iogx";
    description = "print this message";
    exec = print-menu-content;
  };


  env-content = l.prettyTwoColumnsLayout {
    indent = "  ";
    gap-width = 2;
    max-width = 1000;
    lefts = l.attrNames all-envs;
    rights = l.attrValues all-envs;
  };


  print-env-content = ''
    echo
    echo
    echo "${env-content}"
    echo 
  '';


  print-env = {
    group = "iogx";
    description = "print your evironment variables";
    exec = print-env-content;
  };


  utility-module = {
    scripts = { inherit list-haskell-outputs print-env menu list-hydra-jobs; };
    env.PS1 = flakeopts.shellPrompt;
    enterShell = "menu";
  };
in
utility-module
