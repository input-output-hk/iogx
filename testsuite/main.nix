{ inputs, pkgs, lib, ... }:

let

  testsuite = [];


  main = pkgs.writeScript "testsuite" ''
    echo "${lib.deepSeq testsuite "success"}"
  '';

in

  main 

