{ l }:

{ root, module, args, debug ? false }:

let

  fileToModule = dir: path:
    if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        value = import "${dir}/${path}" (args // { ${module} = __module__; });
        trace = l.ptrace ("[modularise] importing ${dir}/${path}");
        value' = if debug then trace value else value;
      in
      l.nameValuePair name value
    else
    # TODO throw or warn instead if path is not a nix file
      l.nameValuePair path null;


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
      l.pthrow "[modularise] unexpected file ${dir}/${path} of type ${type}.";


  mkModule = path:
    if !l.pathExists path then
      l.pthrow "[modularise] path ${path} does not exist."
    else
      (dirToModule "" path).value;


  __module__ = mkModule (l.toPath root);

in

__module__
