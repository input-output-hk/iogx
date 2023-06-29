{ inputs' }:
{ 
  repoRoot = ../.;
  systems = [ "x86_64-linux" ];
  haskellCompilers = [ "ghc8107" ];
}