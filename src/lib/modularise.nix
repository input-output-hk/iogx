iogx-inputs:

{ root, module, args, debug ? false }:

let

  l = builtins // iogx-inputs.nixpkgs.lib;


  fileToModule = dir: path:
    if !l.pathExists "${dir}/${path}" then
      l.throw ("[modularise.nix] there is no file/folder named ${path} in directory ${dir}")
    else if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        # TODO check that import "${dir}/${path}" is a function and warn otherwise
        value = import "${dir}/${path}" (args // { ${module} = __module__; });
        trace = l.trace ("[modularise.nix] importing ${dir}/${path}");
        value' = if debug then trace value else value;
      in
      l.nameValuePair name value
    else # non-Nix file
      l.nameValuePair path (l.readFile "${dir}/${path}");


  dirToModule = dir: path:
    let
      name = path;
      value = l.mapAttrs' (pathToModule "${dir}/${path}") (l.readDir "${dir}/${path}");
    in
    l.nameValuePair name value;


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

in

__module__
