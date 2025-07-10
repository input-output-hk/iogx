# Changelog for IOGX

## 07 Jul 2025

This repo is now a minimal Haskell project template using haskell.nix.
It includes comments and tips, and sets up a full Haskell toolchain (all major GHC versions) — no API, just the Nix file skeleton.

## 19 Nov 2024

- Removed now-archived `nixpkgs-fmt` in favor of `nixfmt-classic`. 
  
  To migrate, replace:
  ```
  # shell.nix 
  { repoRoot, inputs, pkgs, lib, system }:
  lib.iogx.mkShell {
    tools.nixpkgs-fmt.enable = true;
  }
  ```
  With:
  ```
  # shell.nix 
  { repoRoot, inputs, pkgs, lib, system }:
  lib.iogx.mkShell {
    tools.nixfmt-classic.enable = true;
  }
  ```
  