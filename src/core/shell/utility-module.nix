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


  list-haskell-outputs =
    let
      # formatDevShells =
      #   let
      #     fromGhc = ghc: l.concatStringsSep "\n" [
      #       "nix develop .#${l.ansiBold "${ghc}"}"
      #       "nix develop .#${l.ansiBold "${ghc}-profiled"}"
      #     ];
      #     default =
      #       "nix develop";
      #     all-shells = [ default ] ++ map fromGhc iogx-config.haskellCompilers;
      #   in
      #   l.concatStringsSep "\n" all-shells;

      formatGhc = group: command: ghc:
        if l.hasAttr __flake__.${group} ghc then
          if group == "devShells" then
            []
          else
            let fromName = name: _: "nix ${command} .#${l.ansiBold name}";
            in l.mapAttrsToList fromName __flake__.${group}.${ghc}
        else 
          [];

      formatGroup = group: command: 
        let 
          ghcs = l.mkGhcPrefixMatrix iogx-config.haskellCompilers;
          lists = l.concatMap (formatGroup group command) ghcs;
        in 
          l.concatStringsSep "\n" lists;

      formatted-outputs = l.concatStringsSep "\n\n" [
        (l.ansiColor "Haskell Packages" "yellow" "bold")
        (formatGroup "packages" "build")
        (l.ansiColor "Haskell Apps" "yellow" "bold")
        (formatGroup "apps" "run")
        (l.ansiColor "Haskell Checks" "yellow" "bold")
        (formatGroup "checks" "run")
        (l.ansiColor "Development Shells" "yellow" "bold")
        (formatGroup "devShells" "develop")
      ];

      script = {
        group = "iogx";
        description = "List the Haskell outputs (including hydraJobs) buildable by nix";
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
        "${formatted-script-groups}";

      script = {
        group = "iogx";
        description = "Print this message";
        exec = ''
          printf "${content}"
        '';
      };
    in
    script;


  utility-module = {
    scripts = { 
      inherit info;# list-haskell-outputs; 
    };
  };

in

utility-module
