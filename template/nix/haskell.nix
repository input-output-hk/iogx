# This file is part of the IOGX template and is documented at the link below:
# https://www.github.com/input-output-hk/iogx#32-nixhaskellnix

{ iogx, nix, inputs, inputs', pkgs, system, l, ... }:

{
  supportedCompilers = [ "ghc8107" ];
  # defaultHaskellCompiler = "ghc8107";
  # enableCrossCompilation = false;
  # defaultChangelogPackages = [];
  # enableCombinedHaddock = false; 
  # projectPackagesWithHaddock = [];
  # combinedHaddockPrologue = "";
}
