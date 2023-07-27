{ inputs, inputs', pkgs, iogx-config, l, src, ... }:

{ __shell__, __flake__ }:

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


  list-binaries =
    let
      shell-packages = l.getAttrWithDefault "packages" [] __shell__;

      formatPkg = pkg:
        let 
          name = l.getName pkg.name;
          version = l.getVersion pkg.name;
          description = l.trimTextRight (l.getAttrWithDefault "description" "" pkg.meta) 80 "...";
        in 
          if l.pathExists "${pkg}/bin" then 
            let 
              exes = l.mapAttrsToList (exe: _: exe) (l.readDir "${pkg}/bin"); 
            in 
              if l.length exes == 1 then 
                "— ${l.ansiBold (l.head exes)} ${l.ansiColor version "purple" ""} ∷ ${description}"
              else 
                "— ${l.ansiColor name "yellow" "bold"} ${l.ansiColor version "purple" ""} ∷ ${description}\n  " + 
                l.concatStringsSep "\n  " (map l.ansiBold exes)
          else 
            "";

      formatted-outputs = 
        let  
          filterEmpty = l.filter (s: s != "");
          sortAlphabetically = l.sort (a: b: a < b);
        in 
          l.composeManyLeft [
            (map formatPkg)
            filterEmpty
            sortAlphabetically
            (l.concatStringsSep "\n")
          ] shell-packages;

      script = {
        group = "iogx";
        description = "List all the binaries avaialable in the shell";
        exec = ''
          echo
          printf "${formatted-outputs}"
          echo
        '';
      };
    in
    script;


  list-flake-outputs =
    let
      formatGroup = group: command: 
        if l.hasAttr group __flake__ then
          let 
            mkCommand = name: _: "nix ${command} .#${l.ansiBold name}";
            commands = l.mapAttrsToList mkCommand __flake__.${group};
          in 
            l.concatStringsSep "\n" commands
        else 
          ""; 

      formatted-outputs = l.concatStringsSep "\n\n" [
        (l.ansiColor "packages" "yellow" "bold")
        (formatGroup "packages" "build")
        (l.ansiColor "apps" "yellow" "bold")
        (formatGroup "apps" "run")
        (l.ansiColor "checks" "yellow" "bold")
        (formatGroup "checks" "run")
        (l.ansiColor "devShells" "yellow" "bold")
        (formatGroup "devShells" "develop")
      ];

      script = {
        group = "iogx";
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
          shell-scripts = filterDisabled (l.getAttrWithDefault "scripts" { } __shell__);
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
          shell-env = l.getAttrWithDefault "env" { } __shell__;
          final-env = removeAttrs shell-env [ "NIX_GHC_LIBDIR" "PKG_CONFIG_PATH" "CABAL_CONFIG" "LOCALE_ARCHIVE" ];
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
      inherit info list-flake-outputs;
    };
  };

in

utility-module
