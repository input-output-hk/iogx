{ pkgs, lib, inputs, ... }:

let

  evaluated-modules = lib.evalModules {
    modules = [{
      options = {
        inherit (inputs.self.lib.options)
          # Note: the `.<in>` submodules are rendered implicitly.
          "flake.nix"
          mkFlake
          mkHaskellProject
          mkShell;
      };
    }];
  };


  options-doc = pkgs.nixosOptionsDoc {
    options = evaluated-modules.options;
    transformOptions = opt: opt;
  };


  options-doc-nix = options-doc.optionsNix;


  options-doc-markdown =
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList mkMarkdownForOption options-doc-nix);


  cleanupName = name:
    lib.replaceStrings
      [ "\"<in>\"" "\"<out>\"" "<function body>" ]
      [ "<in>" "<out>" "<func>" ]
      name;


  prettyPrintValue = value:
    if value._type == "literalExpression" && lib.hasInfix "\n" value.text then
      "\n```nix\n${value.text}\n```"
    else if value._type == "literalExpression" && !lib.hasInfix "\n" value.text then
      "`${value.text}`"
    else if value._type != "literalExpression" && lib.hasInfix "\n" value.text then
      "\n```nix\n${lib.toJSON value.text}\n```"
    else if value._type != "literalExpression" && !lib.hasInfix "\n" value.text then
      "`${lib.toJSON value.text}`"
    else
      "";


  mkMarkdownForOption = name: value: ''
    ---

    ### `${cleanupName name}`

    **Type**: ${value.type}

    ${
      if lib.hasAttr "default" value then 
        ''
          **Default**: ${prettyPrintValue value.default}
        ''
      else 
        ""
    }
    ${
      if value.readOnly then "**Read Only**" else ""
    }
    ${ 
      if lib.hasAttr "example" value then 
        ''
          **Example**: ${prettyPrintValue value.example}
        ''
      else 
        ""
    }

    ${value.description}
  '';

in

pkgs.writeText "api.md" ''

    # API Reference 

    1. ${lib.iogx.utils.headerToLocalMarkDownLink "./flake.nix" "flake.nix"} 
        - Top-level ./flake.nix file.
    2. ${lib.iogx.utils.headerToLocalMarkDownLink "inputs.iogx.lib.mkFlake" "mkFlake"} 
        - Makes your flake outputs.
    3. ${lib.iogx.utils.headerToLocalMarkDownLink "pkgs.lib.iogx.mkHaskellProject" "mkHaskellProject"} 
        - Makes a [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project.
    4. ${lib.iogx.utils.headerToLocalMarkDownLink "pkgs.lib.iogx.mkShell" "mkShell"}
        - Makes a `devShell` with `pre-commit-check` and tools.

    ${options-doc-markdown}
  ''



