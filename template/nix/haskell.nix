# This file is part of the IOGX template and is documented at the link below:
# https://www.github.com/input-output-hk/iogx#32-nixhaskellnix

{ inputs', ... }:
{
  supportedCompilers = [ "ghc8107" ];
  # defaultHaskellCompiler = "ghc8107";
  # enableCrossCompilation = false;
  # defaultChangelogPackages = [];
}
