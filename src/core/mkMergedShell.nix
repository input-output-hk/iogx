{ lib, pkgs, ... }:

let
  utils = lib.iogx.utils;


  mergeTwoShellProfiles = p1: p2: {

    packages =
      utils.getAttrWithDefault "packages" [ ] p1 ++
      utils.getAttrWithDefault "packages" [ ] p2;

    scripts =
      let
        scripts1 = utils.getAttrWithDefault "scripts" { } p1;
        scripts2 = utils.getAttrWithDefault "scripts" { } p2;
      in
      # TODO check clashes
      scripts1 // scripts2;

    env =
      let
        env1 = utils.getAttrWithDefault "env" { } p1;
        env2 = utils.getAttrWithDefault "env" { } p2;
      in
      # TODO check clashes
      env1 // env2;

    shellHook =
      lib.concatStringsSep "\n" [
        (utils.getAttrWithDefault "shellHook" "" p1)
        (utils.getAttrWithDefault "shellHook" "" p2)
      ];

    tools =
      let
        tools1 = utils.getAttrWithDefault "tools" { } p1;
        tools2 = utils.getAttrWithDefault "tools" { } p2;
      in
      # TODO check clashes
      tools1 // tools2;

    preCommit =
      let
        pre1 = utils.getAttrWithDefault "preCommit" { } p1;
        pre2 = utils.getAttrWithDefault "preCommit" { } p2;
      in
      # TODO check clashes
      pre1 // pre2;
  };


  mkMergedShell = lib.foldl' mergeTwoShellProfiles { };

in

mkMergedShell
