{ iogx-inputs }:

let
  l = iogx-inputs.nixpkgs.lib // builtins;

  utils = rec {

    composeManyLeft = y: xs: l.foldl' (x: f: f x) xs y;

    mergePrefixFlakes = flake1: flake2: prefix:
      l.recursiveUpdate flake1 (l.mapAttrs (_: value: nestAttrs value [ prefix ]) flake2);

    nestAttrs = l.foldr (prefix: l.mapAttrs (_: value: { ${prefix} = value; }));

    recursiveUpdateMany = l.foldl' l.recursiveUpdate { };

    unwords = l.concatStringsSep " ";

    maximumBy = f: l.foldl' (x: max: if f x > f max then x else max);

    # TODO is this in the stdlib?
    getAttrWithDefault = name: def: set:
      if l.hasAttr name set then
        l.getAttr name set
      else
        def;

    deleteManyAttrsByPathString = l.foldl' (l.flip deleteAttrByPathString);

    deleteAttrByPathString = path: deleteAttrByPath (l.splitString "." path);

    # TODO is this in the stdlib?
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

    # prettyTwoColumnsLayout { 
    #   lefts = ["a" "ccc"]; 
    #   rights = ["longlonglong" "short"]; 
    #   max-width = 16; 
    #   sep-char = "."; 
    #   gap-width = 3; 
    #   ellipse = "***"; 
    # }
    # -> 
    # a.....longlon***
    # ccc...short  
    prettyTwoColumnsLayout =
      { lefts, rights, max-width ? 80, sep-char ? " ", gap-width ? 2, ellipse ? "..", indent ? "" }:
      let
        # TODO are some of these in the stdlib?
        replicate = n: elem: l.genList (_: elem) n;

        padRight = max: str: l.concatStrings (replicate (max - l.stringLength str) sep-char);

        cutRight = max: str:
          if l.stringLength str <= max then
            str
          else
            l.substring 0 (max - l.stringLength ellipse) str + ellipse;

        formatPair = left: right:
          let
            lhs = indent + left;
            padding = padRight (max-lefts + gap-width) left;
            rhs = cutRight (max-width - max-lefts - gap-width - l.stringLength indent) right;
          in
          "${lhs}${padding}${rhs}";

        max-lefts = l.stringLength (maximumBy l.stringLength "" lefts);

        lines = l.zipListsWith formatPair lefts rights;

        final-str = l.concatStringsSep "\n" lines;
      in
      final-str;

  };

in

utils // l

# builtins.trace ("\n" + outputs.ext.marlowe-cardano.l.x86_64-darwin.prettyTwoColumnsLayout { lefts = ["a" "ccc"]; rights = ["longlonglong" "short"]; max-width = 16; sep-char = "."; gap-width = 3; ellipse = "***"; }) ""
