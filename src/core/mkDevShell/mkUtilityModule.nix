{ inputs, pkgs, flakeopts, iogx, l, ... }:

{ flake, core-modules }:

let
  filterDisabledScripts =
    l.filterAttrs (_: { enabled ? true, ... }: enabled);


  extractScriptNames =
    l.attrNames;


  extractScriptDescriptions =
    l.mapAttrsToList (_: l.getAttrWithDefault "description" "");


  extractScriptGroup =
    l.mapAttrsToList (_: l.getAttrWithDefault "group" "");


  getAndFilterDisabledScripts = mod:
    filterDisabledScripts (l.getAttrWithDefault "scripts" { } mod);


  all-packages =
    l.concatMap (l.getAttrWithDefault "packages" [ ]) core-modules;


  all-scripts =
    l.recursiveUpdateMany (map getAndFilterDisabledScripts core-modules);


  formatFlakeOutputs = group: command:
    if group == "devShells" then
      let fromGhc = ghc: "nix develop .#${ghc}\nnix develop .#${ghc}-profiled";
      in l.concatStringsSep "\n" (map fromGhc flakeopts.haskellCompilers)
    else
      let fromName = name: _: "nix ${command} .#${name}";
      in l.concatStringsSep "\n" (l.mapAttrsToList fromName flake.${group});


  formatted-haskell-outputs = ''
    ******************** Haskell Packages ********************

    ${formatFlakeOutputs "packages" "build"}

    ******************** Haskell Apps ******************** 

    ${formatFlakeOutputs "apps" "run"}

    ******************** Development Shells ******************** 

    ${formatFlakeOutputs "devShells" "develop"}
  '';


  list-haskell-outputs = {
    description = "list the haskell outputs buildable by nix";
    exec = ''echo "${formatted-haskell-outputs}"'';
  };


  menu-content =
    let
      extra-names =
        [ "list-haskell-outputs" "menu" ];
      extra-descriptions =
        [ list-haskell-outputs.description menu.description ];
      content =
        l.prettyTwoColumnsLayout {
          indent = "👉 ";
          gap-width = 4;
          lefts = extra-names ++ extractScriptNames all-scripts;
          rights = extra-descriptions ++ extractScriptDescriptions all-scripts;
        };
    in
    content;


  print-menu-content = ''
    echo
    echo
    echo -e "🤟 \033[1;31m${flakeopts.shellName}\033[0m development shell"
    echo 
    echo "${menu-content}"
    echo
    echo
  '';


  menu = {
    description = "print this message";
    exec = print-menu-content;
  };


  utility-module = {
    scripts = { inherit list-haskell-outputs menu; };
    enterShell = ''
      export PS1="${flakeopts.shellPrompt}"
      menu
    '';
  };
in
utility-module
