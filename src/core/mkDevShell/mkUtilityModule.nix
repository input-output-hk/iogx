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


  list-haskell-outputs =
    let
      formatGroup = group: command:
        if group == "devShells" then
          let fromGhc = ghc: "nix develop .#${ghc}\nnix develop .#${ghc}-profiled";
          in l.concatStringsSep "\n" (map fromGhc flakeopts.haskellCompilers)
        else
          let fromName = name: _: "nix ${command} .#${name}";
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
          extra-scripts = { inherit info list-haskell-outputs; };
        in
        mods-scripts // extra-scripts;

      formatGroup = group: scripts:
        let
          formatScript = name: script: ''
            — ${l.ansiColor name "white" "bold"} ∷ ${script.description or ""}
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
            — ${l.ansiColor var "white" "bold"} ∷ ${val}
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
    scripts = { inherit list-haskell-outputs info; };
    env.PS1 = flakeopts.shellPrompt;
    enterShell = "info";
  };
in
utility-module
