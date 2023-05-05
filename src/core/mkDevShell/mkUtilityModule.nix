{ inputs, pkgs, flakeopts, iogx, l, ... }:

{ flake, core-modules }:

let
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

      in l.concatStringsSep "\n" (l.mapAttrsToList fromName flake.${group});


  # TODO take into account
  # excludeProfiledHaskellFromHydraJobs 
  # blacklistedHydraJobs 
  # enableHydraPreCommitCheck 
  list-hydra-jobs =
    let
      formatSimple = system:
        let nix-build = "nix build .#hydraJobs.${system}.";
        in name: "${nix-build}${flake-prefix}${l.ansiBold name}";

      formatGroup = system: group:
        let
          nix-build = "nix build .#hydraJobs.${system}.";
          formatOne = name: _: "${nix-build}${flake-prefix}${group}.${l.ansiBold name}";
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

      formatted-hydra-jobs =
        l.concatStringsSep "\n" (map formatSystem flakeopts.systems);

      script = {
        group = "iogx";
        description = "List everything that can be built by CI";
        exec = ''
          echo
          printf "${formatted-hydra-jobs}"
          echo
        '';
      };
    in
    script;


  list-haskell-outputs =
    let
      formatDevShells =
        let
          fromGhc = ghc: l.concatStringsSep "\n" [
            "nix develop .#${flake-prefix}${l.ansiBold "${ghc}-default"}"
            "nix develop .#${flake-prefix}${l.ansiBold "${ghc}-default-profiled"}"
          ];
          default =
            if flake-prefix == ""
            then "nix develop"
            else "nix develop .#${flake-prefix}${l.ansiBold "default"}";
          all-shells = [ default ] ++ map fromGhc flakeopts.haskellCompilers;
        in
        l.concatStringsSep "\n" all-shells;

      formatGroup = group: command:
        if group == "devShells" then
          formatDevShells
        else
          let fromName = name: _: "nix ${command} .#${flake-prefix}${l.ansiBold name}";
            # NOTE: at this point the flakeOutputsPrefix has not been added to the 
            # flake, that's why we can do flake.${group} and not 
            # flake.${group}.formatFlakeOutputs
          in l.concatStringsSep "\n" (l.mapAttrsToList fromName flake.${group});

      formatted-outputs = l.concatStringsSep "\n\n" [
        (l.ansiColor "Haskell Packages" "yellow" "bold")
        (formatGroup "packages" "build")
        (l.ansiColor "Haskell Apps" "yellow" "bold")
        (formatGroup "apps" "run")
        (l.ansiColor "Development Shells" "yellow" "bold")
        (formatGroup "devShells" "develop")
      ];

      script = {
        group = "iogx";
        description = "List the haskell outputs buildable by nix";
        exec = ''
          echo
          printf "${formatted-outputs}"
          echo
        '';
      };
    in
    script;


  info =
    let
      all-scripts =
        let
          filterDisabled = l.filterAttrs (_: { enabled ? true, ... }: enabled);
          getModuleScripts = mod: filterDisabled (l.getAttrWithDefault "scripts" { } mod);
          mods-scripts = l.recursiveUpdateMany (map getModuleScripts core-modules);
          extra-scripts = { inherit info list-haskell-outputs list-hydra-jobs; };
        in
        mods-scripts // extra-scripts;

      formatGroup = group: scripts:
        let
          formatScript = name: script: ''
            — ${l.ansiBold name} ∷ ${script.description or ""}
          '';
          formatted-group = l.concatStrings (l.mapAttrsToList formatScript scripts);
        in
        ''
          ${l.ansiColor "λ ${group}" "yellow" "bold"}
          ${formatted-group}
        '';

      formatted-script-groups =
        let groups = partitionScriptsByGroup all-scripts;
        in l.concatStrings (l.mapAttrsToList formatGroup groups);

      formatted-env =
        let
          getEnv = l.getAttrWithDefault "env" { };
          merged-env = l.recursiveUpdateMany (map getEnv core-modules);
          final-env = removeAttrs merged-env [ "NIX_GHC_LIBDIR" "PKG_CONFIG_PATH" ];
          formatVar = var: val: ''
            — ${l.ansiBold var} ∷ ${val}
          '';
          content = l.concatStrings (l.mapAttrsToList formatVar final-env);
        in
        ''
          ${l.ansiColor "λ environment" "purple" "bold"}
          ${content}
        '';

      script = {
        group = "iogx";
        description = "Print this message";
        exec = ''
          printf "\n${flakeopts.shellWelcomeMessage}\n\n"
          printf "${formatted-env}"
          printf "${formatted-script-groups}"
        '';
      };
    in
    script;


  utility-module = {
    scripts = { inherit list-haskell-outputs list-hydra-jobs info; };
    env.PS1 = flakeopts.shellPrompt;
    enterShell = "info";
  };
in
utility-module
