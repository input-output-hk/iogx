{ pkgs, src, ... }:

{ per-commit-check }:

{
  packages = [pkgs.pre-commit];

  enterShell = pre-commit-check.shellHook;
}
