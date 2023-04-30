{ l }:

{ root, module, args }:

let
  fileToModule = dir: path:
    if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        value = import "${dir}/${path}" (args // { ${module} = __module__; });
      in
      l.nameValuePair name value
    else
      l.nameValuePair path null;
  # TODO 
  # l.throw "[modularise] ${path} is not a nix file.";

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
      l.throw "[modularise] unexpected file ${dir}/${path} of type ${type}.";

  mkModule = path:
    if !l.pathExists path then
      l.throw "[modularise] path ${path} does not exist."
    else
      (dirToModule "" path).value;

  __module__ = mkModule (l.toPath root);
in
__module__
