{ pkgs, inputs, ... }:

pkgs.callPackage inputs.sphinxcontrib-haddock {
  pythonPackages = pkgs.python3Packages;
}
