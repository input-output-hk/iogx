iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;


  utils = rec {

    composeManyLeft = y: xs: l.foldl' (x: f: f x) xs y;


    # FIXME ensure that recursion stops when encountering values of type Derivation
    recursiveUpdateMany = l.foldl' l.recursiveUpdate { };


    mapAndRecursiveUpdateMany = xs: f: recursiveUpdateMany (map f xs);


    ptrace = x: y: l.trace (valueToString x) y;


    ptraceAttrNames = s: l.trace (l.attrNames s) s;


    ptraceShow = x: ptrace x x;


    hasAttrByPathString = p: s: l.hasAttrByPath (l.splitString "." p) s;


    valueToString = x:
      if x == null then
        "null"
      else if l.typeOf x == "set" then
        "{${l.concatStringsSep " " (l.mapAttrsToList (k: v: "${k}=${valueToString v};") x)}}"
      else if l.typeOf x == "list" then
        "[${l.concatStringsSep " " (map valueToString x)}]"
      else if l.typeOf x == "string" then
        ''"${x}"''
      else if l.typeOf x == "bool" then
        if x then "true" else "false"
      else if l.typeOf x == "lambda" then
        "<LAMBDA>"
      else
        toString x;


    mergeDisjointAttrsOrThrow = s1: s2: mkErrmsg:
      let
        duplicates = l.intersectLists (l.attrNames s1) (l.attrNames s2);
        n = l.length duplicates;
      in
      if n > 0 then
        pthrow (mkErrmsg { inherit n duplicates; })
      else
        s1 // s2;


    allEquals = xs:
      if l.length xs > 0 then
        let
          ts = map l.typeOf xs;
          ht = l.head ts;
          hx = l.head xs;
        in
        l.all (t: t == ht) ts && l.all (x: x == hx) ts
      else
        true;


    # Is this not in the stdlib?
    getAttrWithDefault = name: def: set:
      if l.hasAttr name set then
        l.getAttr name set
      else
        def;


    getAttrByPathString = path: l.getAttrFromPath (l.splitString "." path);


    # FIXME Probably this function is very inefficient 
    restrictManyAttrsByPathString = paths: set:
      let
        parts = map (l.flip restrictAttrByPathString set) paths;
      in
      recursiveUpdateMany parts;


    restrictAttrByPath = path: set:
      if l.hasAttrByPath path set then
        l.setAttrByPath path (l.getAttrFromPath path set)
      else
        { };


    restrictAttrByPathString = path: restrictAttrByPath (l.splitString "." path);


    deleteManyAttrsByPathString = paths: set: l.foldl' (l.flip deleteAttrByPathString) set paths;


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


    ansiColor = text: fg: style:
      let
        colors = {
          black = "30";
          red = "31";
          green = "32";
          yellow = "33";
          blue = "34";
          purple = "35";
          cyan = "36";
          white = "37";
        };

        colorBit = getAttrWithDefault fg "white" colors;

        boldBit = if style == "bold" then "1" else "0";
      in
      "\\033[${boldBit};${colorBit}m${text}\\033[0m";


    shellEscape = s: (l.replaceStrings [ "\\" ] [ "\\\\" ] s);


    ansiBold = text: ansiColor text "white" "bold";


    ansiColorEscaped = text: fg: style: shellEscape (ansiColor text fg style);


    pkgToExec = pkg: ''
      ${l.getExe pkg} "$@"
    '';


    plural = n: s: if n == -1 || n == 1 then s else "${s}s";


    mapAttrValues = f: l.mapAttrs (_: f);


    # Odd that this isn't a builtin. 
    attrsSize = s: l.length (l.attrNames s);


    pthrow = text:
      l.throw "\n${text}";


    iogxError = file: errmsg:
      let
        readme-anchor = {
          flake = "31-flakenix";
          haskell = "32-nixhaskellnix";
          cabal-project = "33-nixcabal-projectnix";
          shell = "34-nixshellnix";
          per-system-outputs = "35-nixper-system-outputsnix";
          top-level-outputs = "36-nixtop-level-outputsnix";
          read-the-docs = "37-nixread-the-docsnix";
          formatters = "38-nixformattersnix";
          ci = "39-nixcisnix";
        }.${file};
      in
      l.throw ''
        
        ------------------------------------ IOGX --------------------------------------
        ${errmsg}
        Follow this link for documentation:
        https://www.github.com/input-output-hk/iogx#${readme-anchor}
        --------------------------------------------------------------------------------
      '';


    iogxTrace = errmsg:
      l.trace ''
        
        ------------------------------------ IOGX --------------------------------------
        ${errmsg}
        --------------------------------------------------------------------------------
      '';


    # Stolen from https://github.com/divnix/nosys
    deSystemize =
      let
        iteration = cutoff: system: fragment:
          if ! (l.isAttrs fragment) || cutoff == 0 then
            fragment
          else
            let recursed = l.mapAttrs (_: iteration (cutoff - 1) system) fragment; in
            if l.hasAttr "${system}" fragment then
              if l.isFunction fragment.${system} then
                recursed // { __functor = _: fragment.${system}; }
              else
                recursed // fragment.${system}
            else
              recursed;
      in
      iteration 3;


    mapMaybe = f: xs: builtins.filter (x: x != null) (map f xs);


    filterEmptyStrings = l.filter (x: x != "");


    injectAttrName = n: l.mapAttrs' (k: v: l.nameValuePair k { ${n} = v; });


    findDuplicates = list:
      map l.head (
        l.attrValues (
          l.filterAttrs
            (k: v: l.length v > 1)
            (l.groupBy toString list)
        )
      );

  };

in

utils
