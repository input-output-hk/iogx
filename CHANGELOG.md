# Changelog for IOGX

## 19 Nov 2024

- Removed now-archived `nixpkgs-fmt` in favor of `nixfmt`. 
  
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
    tools.nixfmt.enable = true;
  }
  ```
  