{ l }:

{ args, src, module }:

let
  fileToModule = root: path:
    if l.hasSuffix ".nix" path then
      let
        name = l.removeSuffix ".nix" path;
        value = import "${root}/${path}" (args // { "${module}" = __module__; });
      in
      l.nameValuePair name value
    else
      l.nameValuePair path null;
  # TODO 
  # l.throw "[modularise] ${path} is not a nix file.";

  dirToModule = root: path:
    let
      name = path;
      value = l.mapAttrs' (pathToModule "${root}/${path}") (l.readDir "${root}/${path}");
    in
    l.nameValuePair name value;

  pathToModule = root: path: type:
    if type == "directory" then
      dirToModule root path
    else if type == "regular" then
      fileToModule root path
    else
      l.throw "[modularise] unexpected file ${root}/${path} of type ${type}.";

  mkModule = path:
    if !l.pathExists path then
      l.throw "[modularise] path ${src} does not exist."
    else
      (dirToModule "" path).value;

  __module__ = mkModule (l.toPath src);
in
__module__
