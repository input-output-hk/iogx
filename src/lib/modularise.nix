{ l }:

{ root, module, args, debug ? false }:

let

  fileToModule = dir: path:
    if !l.pathExists "${dir}/${path}" then
      l.pthrow ("[modularise] there is no file/folder named ${path} in directory ${dir}")
    else if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        value = import "${dir}/${path}" (args // { ${module} = __module__; });
        trace = l.ptrace ("[modularise] importing ${dir}/${path}");
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
      l.pthrow "[modularise] unexpected file ${dir}/${path} of type ${type}.";


  mkModule = path:
    if !l.pathExists path then
      l.pthrow "[modularise] path ${path} does not exist."
    else
      (dirToModule "" path).value;


  __module__ = mkModule (l.toPath root);

in

__module__
