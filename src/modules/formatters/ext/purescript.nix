{ pkgs, inputs, ... }:
let
  p = pkgs.callPackage inputs.easy-purescript-nix { };
in
p // { purs = p.purs-0_15_2; }
