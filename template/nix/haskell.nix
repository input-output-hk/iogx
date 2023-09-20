# This file is part of the IOGX template and is documented at the link below:
# https://www.github.com/input-output-hk/iogx#32-nixhaskellnix

{ iogxRepoRoot, repoRoot, inputs, inputs', pkgs, system, lib, ... }:

{
  supportedCompilers = [ "ghc8107" ];
  # defaultHaskellCompiler = "ghc8107";
  # enableCrossCompilation = false;
  # defaultChangelogPackages = [];
  # enableCombinedHaddock = false; 
  # projectPackagesWithHaddock = [];
  # combinedHaddockPrologue = "";
}
