{ src, iogx-inputs, iogx-interface, inputs, inputs', pkgs, l, __flake__, ... }:

shell-profile: # The target shell-profile

let

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


  list-flake-outputs =
    let
      formatGroup = group: command:
        if l.hasAttr group __flake__ && __flake__.${group} != { } then
          let
            mkCommand = name: _: "nix ${command} .#${l.ansiBold name}";
            commands = l.mapAttrsToList mkCommand __flake__.${group};
          in
          ''
            ${l.ansiColor group "yellow" "bold"}

            ${l.concatStringsSep "\n" commands}''
        else
          "";

      formatted-outputs = l.concatStringsSep "\n\n" (l.filterEmptyStrings [
        (formatGroup "packages" "build")
        (formatGroup "apps" "run")
        (formatGroup "checks" "run")
        (formatGroup "devShells" "develop")
      ]);

      script = {
        group = "general";
        description = "List the flake outputs buildable by nix";
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
          filterDisabled = l.filterAttrs (_: { enable ? true, ... }: enable);
          shell-scripts = filterDisabled (l.getAttrWithDefault "scripts" { } shell-profile);
          extra-scripts = { inherit info list-flake-outputs; };
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
          internal-vars = [
            "NIX_GHC_LIBDIR"
            "PKG_CONFIG_PATH"
            "CABAL_CONFIG"
            "LOCALE_ARCHIVE" # TODO add LOCALE_ARCHIVE to shell
          ];
          shell-env = l.getAttrWithDefault "env" { } shell-profile;
          final-env = removeAttrs shell-env internal-vars;
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
        l.optionalString (formatted-env != "") formatted-env +
        "${formatted-script-groups}";

      script = {
        group = "general";
        description = "Print this message";
        exec = ''
          echo
          printf "${content}"'';
      };
    in
    script;


  utility-scripts-shell-profile = {
    scripts = { inherit info list-flake-outputs; };
  };

in

utility-scripts-shell-profile
