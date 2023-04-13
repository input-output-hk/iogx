{ systemized-inputs }:

let
  l = systemized-inputs.nixpkgs.lib;

  utils = rec {
    # nestAttrs = prefix: l.mapAttrs (_: value: { ${prefix} = value; });

    # Attrs Prefixes
    nestAttrs = l.foldr (prefix: l.mapAttrs (_: value: { ${prefix} = value; }));

    recursiveUpdateMany = l.foldl' l.recursiveUpdate { };

    unwords = l.concatStringsSep " ";

    deleteManyAttrsByPathString = l.foldl' (l.flip deleteAttrByPathString);

    deleteAttrByPathString = path: deleteAttrByPath (l.splitString "." path);

    deleteAttrByPath = path: set:
      if l.length path == 0 then
        set
      else if l.length path == 1 then
        let
          name = builtins.head path;
        in
        if l.hasAttr name set then
          removeAttrs set [ name ]
        else
          set
      else
        let
          name = builtins.head path;
          rest = builtins.tail path;
        in
        if l.hasAttr name set then
          set // { ${name} = deleteAttrByPath rest set.${name}; }
        else
          set;
  };

in

utils // l
