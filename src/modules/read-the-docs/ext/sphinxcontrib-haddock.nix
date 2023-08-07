{ iogx-inputs, pkgs, ... }:

pkgs.callPackage iogx-inputs.sphinxcontrib-haddock {
  pythonPackages = pkgs.python3Packages;
}
