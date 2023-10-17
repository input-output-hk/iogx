{ pkgs, lib, user-inputs, system, ... }:

shell:

let

  utils = lib.iogx.utils;


  partitionScriptsByGroup = scripts:
    let
      getGroup = script: utils.getAttrWithDefault "group" "ungrouped" script.value;
      nameValToScript = script: { "${script.name}" = script.value; };
      groupToScripts = _: namevals: utils.recursiveUpdateMany (map nameValToScript namevals);
      pairs = lib.mapAttrsToList lib.nameValuePair scripts;
      groups = lib.groupBy getGroup pairs;
      partitioned = lib.mapAttrs groupToScripts groups;
    in
    partitioned;


  list-flake-outputs =
    let
      formatGroup = group: command:
        if lib.hasAttr group user-inputs.self && user-inputs.self.${group} != { } then
          let
            mkCommand = name: _: "nix ${command} .#${utils.ansiBold name}";
            commands = lib.mapAttrsToList mkCommand user-inputs.self.${group}.${system};
          in
          ''
            ${utils.ansiColor group "yellow" "bold"}

            ${lib.concatStringsSep "\n" commands}''
        else
          "";

      formatted-outputs = lib.concatStringsSep "\n\n" (utils.filterEmptyStrings [
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
          filterDisabled = lib.filterAttrs (_: { enable ? true, ... }: enable);
          shell-scripts = filterDisabled (utils.getAttrWithDefault "scripts" { } shell);
          extra-scripts = { inherit info list-flake-outputs; };
        in
        shell-scripts // extra-scripts;

      formatGroup = group: scripts:
        let
          formatScript = name: script: ''
            — ${utils.ansiBold name} ∷ ${script.description or ""}
          '';
          formatted-group = lib.concatStrings (lib.mapAttrsToList formatScript scripts);
        in
        ''
          ${utils.ansiColor "λ ${group}" "yellow" "bold"}
          ${formatted-group}
        '';

      formatted-script-groups =
        let groups = partitionScriptsByGroup all-scripts;
        in lib.concatStrings (lib.mapAttrsToList formatGroup groups);

      formatted-env =
        let
          internal-vars = [
            "NIX_GHC_LIBDIR"
            "PKG_CONFIG_PATH"
            "CABAL_CONFIG"
            "LOCALE_ARCHIVE"
          ];
          shell-env = utils.getAttrWithDefault "env" { } shell;
          final-env = removeAttrs shell-env internal-vars;
          formatVar = var: val: ''
            — ${utils.ansiBold var} ∷ ${val}
          '';
          body = lib.concatStrings (lib.mapAttrsToList formatVar final-env);
          content = if body == "" then "" else ''
            ${utils.ansiColor "λ environment" "purple" "bold"}
            ${body}
          '';
        in
        content;

      content =
        lib.optionalString (formatted-env != "") formatted-env +
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


  utility-scripts = { inherit info list-flake-outputs; };

in

utility-scripts
