# This file contains utility functions that are used by the iogx codebase.
# The iogx flake exports it in `inputs.iogx.lib.utils`.

iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = rec {

    # When rendered, each header in and .md file gets its own url. 
    # The url is constructed by sanitizing the header's text.
    # This function takes the desired link's display text and the header's text
    # and returns a valid markdown link.
    headerToMarkDownLink = tag: text:
      let
        text' = l.replaceStrings [ "<" ">" "." " " ] [ "" "" "" "-" ] text;
        text-lower = l.strings.toLower text';
      in "[`${tag}`](#${text-lower})";

    recursiveUpdateMany = l.foldl' l.recursiveUpdate { };

    ptrace = x: y: l.trace (valueToString x) y;
    ptraceAttrNames = s: l.trace (l.attrNames s) s;
    ptraceShow = x: ptrace x x;

    valueToString = x:
      if x == null then
        "null"
      else if l.typeOf x == "set" then
        "{${
          l.concatStringsSep " "
          (l.mapAttrsToList (k: v: "${k}=${valueToString v};") x)
        }}"
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

    # Is this not in the stdlib?
    getAttrWithDefault = name: def: set:
      if l.hasAttr name set then l.getAttr name set else def;

    ansiColor = text: fg: style:
      let
        colors = {
          black = ";30";
          red = ";31";
          green = ";32";
          yellow = ";33";
          blue = ";34";
          purple = ";35";
          cyan = ";36";
          white = ";37";
        };

        colorBit = getAttrWithDefault fg "" colors;

        boldBit = if style == "bold" then "1" else "0";
      in "\\033[${boldBit}${colorBit}m${text}\\033[0m";

    ansiBold = text: ansiColor text "" "bold";

    mapAttrValues = f: l.mapAttrs (_: f);

    iogxThrow = errmsg:
      l.throw ''

        ------------------------------------ IOGX --------------------------------------
        ${errmsg}
        --------------------------------------------------------------------------------
      '';

    iogxTrace = errmsg:
      l.trace ''

        ------------------------------------ IOGX --------------------------------------
        ${errmsg}
        --------------------------------------------------------------------------------
      '';

    # Stolen from https://github.com/divnix/nosys
    deSystemize = let
      iteration = cutoff: system: fragment:
        if !(l.isAttrs fragment) || cutoff == 0 then
          fragment
        else
          let recursed = l.mapAttrs (_: iteration (cutoff - 1) system) fragment;
          in if l.hasAttr "${system}" fragment then
            if l.isFunction fragment.${system} then
              recursed // { __functor = _: fragment.${system}; }
            else
              recursed // fragment.${system}
          else
            recursed;
    in iteration 3;

    filterEmptyStrings = l.filter (x: x != "");

    findDuplicates = list:
      map l.head (l.attrValues
        (l.filterAttrs (k: v: l.length v > 1) (l.groupBy toString list)));

    mkApiFuncOptionType = type-in: type-out:
      l.mkOptionType {
        name = "core-API-function";
        description = "Core API Function";
        getSubOptions = prefix:
          type-in.getSubOptions (prefix ++ [ "<in>" ])
          // type-out.getSubOptions (prefix ++ [ "<out>" ]);
      };
  };

in utils
