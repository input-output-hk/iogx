# This file provides a function to import a directory and its contents as a nix
# attribute set. The iogx flake exports it in `inputs.iogx.lib.modularise`.

iogx-inputs:

{
# The path to the folder to be imported (e.g. inputs.self or ../my/folder)
root
# The string to use as the name of the folder (e.g. "root" or "src")
, module
# An attrset of arguments to pass to each nix files.
# The final attrset will also have an attribute with a name equal to the value
# of `module`
, args
# If true, debug information will be traced as files are read and evaluated
, debug ? false }:

# Often in nix code the same variables are passed around to different nix files. 
# Hance why most nix files are functions from an attrset (containing some common 
# variables) to some another nix value.
# Ordinarily one would use the `import` keyword to import nix files, followed by 
# the common arguments. 
# modularise.nix provides a way to avoid this boilerplate by allowing you to 
# reference a folder and its contents as a nix attrset, assuming that the nix 
# files inside that folder are all functions taking a known attrset.

let

  usage-example = let
    # The contents of ./some/existing/folder:
    #     - cabal.project 
    #     - main.nix
    #     * src 
    #       - Main.hs 
    #     * nix
    #       - outputs.nix
    #       - alpha.nix
    #       * bravo
    #         - charlie.nix 
    #         - india.nix
    #         - hotel.json
    #         * delta 
    #           - echo.nix
    #           - golf.txt
    # 
    # The conents of nix/alpha.nix:
    #      { my-folder, my, common, vars, ... }:
    #      "result"
    # 
    # The conents of nix/bravo/charlie.nix:
    #      { my-folder, my, common, vars, ... }:
    #      my-folder."cabal.project"
    #
    example-module = import ./modularise.nix {
      root = ./some/existing/folder;
      module = "my-folder";
      args = {
        my = "my-value";
        common = "common-value";
        vars = [ ];
      };
    };

    # NOTE: nix files do not need the ".nix" suffix, while files with any other 
    # extension (e.g. `golf.txt`) must include the full name to be referenced.
    # In the case of non-nix files, internally modularise.nix calls 
    # `builtins.readFile` to read the contents of that file.
    some-result = let
      a = example-module.nix.alpha;
      c = example-module.nix.bravo.charlie;
      e = example-module.nix.bravo.delta.echo "arg1" { };
      f = example-module.nix.bravo.delta."golf.txt";
      g = example-module.src."Main.hs";
    in 42;
  in some-result;

  l = builtins // iogx-inputs.nixpkgs.lib;

  fileToModule = dir: path:
    if !l.pathExists "${dir}/${path}" then
      l.throw
      ("[modularise.nix] there is no file/folder named ${path} in directory ${dir}")
    else if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        # TODO check that import "${dir}/${path}" is a function and warn otherwise
        value = import "${dir}/${path}" (args // { ${module} = __module__; });
        trace = l.trace ("[modularise.nix] importing ${dir}/${path}");
        value' = if debug then trace value else value;
      in l.nameValuePair name value
    else # non-Nix file
      l.nameValuePair path (l.readFile "${dir}/${path}");

  dirToModule = dir: path:
    let
      name = path;
      value = l.mapAttrs' (pathToModule "${dir}/${path}")
        (l.readDir "${dir}/${path}");
    in l.nameValuePair name value;

  pathToModule = dir: path: type:
    if type == "directory" then
      dirToModule dir path
    else if type == "regular" then
      fileToModule dir path
    else
      l.throw "[modularise.nix] unexpected file ${dir}/${path} of type ${type}";

  mkModule = path:
    if !l.pathExists path then
      l.throw "[modularise.nix] path ${path} does not exist"
    else
      (dirToModule "" path).value;

  __module__ = mkModule (l.toPath root);

in __module__
