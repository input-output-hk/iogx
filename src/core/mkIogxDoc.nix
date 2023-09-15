{ pkgs, lib, inputs, ... }:

let

  evaluated-modules = lib.evalModules {
    modules = [{
      options = { inherit (inputs.self.lib.options) mkFlake mkProject mkShell; };
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


  cleanupName = name: lib.replaceStrings [ "\"<in>\"" "\"<out>\"" "<function body>"] [ "<in>" "<out>" "<func>" ] name;


  prettyPrintValue = header: value:
    if value._type == "literalExpression"then
      "\n```nix\n${header}\n${value.text}\n```"
    else 
      "\n```nix\n${header}\n${lib.toJSON value.text}\n```";


  mkMarkdownForOptionOld = name: value: ''
    ---

    ### `${cleanupName name}` :: ${value.type}

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

  mkMarkdownForOption = name: value: ''
    ---

    <h2>`${cleanupName name}`</h2> :: ${value.type}

    ${
      if lib.hasAttr "default" value 
      then prettyPrintValue "# Default:" value.default
      else ""
    }
        ${
      if lib.hasAttr "example" value 
      then prettyPrintValue "# Example:" value.example
      else ""
    }
    ${value.description}
  '';

in

lib.toFile "options.md" ''
  # Options Reference 

  1. [`inputs.iogx.lib.mkFlake`](#TODO) 
    - Makes the final flake outputs.
  2. [`pkgs.lib.iogx.mkProject`](#TODO) 
    - Makes a [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project decorated with the `iogx` overlay.
  3. [`pkgs.lib.iogx.mkShell`](#TODO) 
    - Makes a `devShell` with `pre-commit-check` and tools.

  ${options-doc-markdown}
''


