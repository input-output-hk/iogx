{ inputs, inputs', pkgs, iogx-config, l, src, ... }:

{ __shell__, __flake__ }:

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
          filterDisabled = l.filterAttrs (_: { enable ? true, ... }: enable);
          shell-scripts = filterDisabled (l.getAttrWithDefault "scripts" { } __shell__);
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
          shell-env = l.getAttrWithDefault "env" { } __shell__;
          final-env = removeAttrs shell-env [ "NIX_GHC_LIBDIR" "PKG_CONFIG_PATH" ];
          formatVar = var: val: ''
            — ${l.ansiBold var} ∷ ${val}
          '';
          body = l.concatStrings (l.mapAttrsToList formatVar final-env);
          content = if body == "" then "" else ''
            ${l.ansiColor "λ environment" "purple" "bold"}
            ${body}
          '';
        in
          content;

      content = 
        "\n${__shell__.welcomeMessage}\n\n" + 
        l.optionalString (formatted-env != "") formatted-env + 
        "\n${formatted-script-groups}";

      script = {
        group = "iogx";
        description = "Print this message";
        exec = ''
          printf ${content}
        '';
      };
    in
    script;


  utility-module = {
    scripts = { inherit info; };
  };

in

utility-module
