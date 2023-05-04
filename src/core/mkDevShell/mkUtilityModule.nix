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


  formatFlakeOutputs = group: command:
    if group == "devShells" then
      let fromGhc = ghc: "nix develop .#${ghc}\nnix develop .#${ghc}-profiled";
      in l.concatStringsSep "\n" (map fromGhc flakeopts.haskellCompilers)
    else
      let fromName = name: _: "nix ${command} .#${name}";
      in l.concatStringsSep "\n" (l.mapAttrsToList fromName flake.${group});


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
        inherit menu print-env list-haskell-outputs;
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
    scripts = { inherit list-haskell-outputs print-env menu; };
    env.PS1 = flakeopts.shellPrompt;
    enterShell = "menu";
  };
in
utility-module
