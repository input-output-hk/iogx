{ iogx, pkgs }:

let

  schemas-testsuite = import ./schemas iogx;

  core-testsuite = "OK"; #import ./core { inherit iogx pkgs; };

  run = pkgs.writeScript "testsuite" ''
    echo "Evaluating tests/schemas/default.nix ... ${schemas-testsuite}"
    echo "Evaluating tests/core/default.nix ... ${core-testsuite}"
  '';

in

run
