{ inputs, inputs', iogx-config, pkgs, l, src, ... }:

{ shell }:

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


  info =
    let
      all-scripts =
        let
          filterDisabled = l.filterAttrs (_: { enabled ? true, ... }: enabled);
          shell-scripts = filterDisabled (l.getAttrWithDefault "scripts" { } shell);
          extra-scripts = { inherit info; };
        in
        shell-scripts // extra-scripts;

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
          shell-env = l.getAttrWithDefault "env" { } shell;
          final-env = removeAttrs shell-env [ "NIX_GHC_LIBDIR" "PKG_CONFIG_PATH" ];
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
          printf "\n${shell.welcomeMessage}\n\n"
          printf "${formatted-env}"
          printf "${formatted-script-groups}"
        '';
      };
    in
    script;


  utility-module = {
    scripts = { inherit info; };
  };

in

utility-module
