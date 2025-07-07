# IOGX — Flake Templates for Your Project <!-- omit in toc -->
- [1. Introduction](#1-introduction)
- [2. Features](#2-features)

# 1. Introduction 

IOGX is a Nix template for your haskell.nix project.

Make sure that you have [installed and configured](./doc/nix-setup-guide.md) nix on your system.

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx#haskell
```

These will generates a `flake.nix` and a `nix` folder in your repository root.

# 2. Features

### GHC Build Matrices <!-- omit in toc -->

Define a set of GHC configurations for your Haskell project using `haskell.nix`'s flake variants, and for each variant you will get `devShells`, `packages`, `apps`, `checks` and `hydraJobs`. 

### Extensible Development Shells <!-- omit in toc -->
  
`devShells` come with a complete Haskell toolchain, and they can be easily extended with new packages, custom scripts, environment variables and hooks.

### Automatic Hydra Jobset <!-- omit in toc -->
    
By default your `hydraJobs` will include every component in your Haskell project, and your test suites will run in CI. 

### Easy Code Formatting <!-- omit in toc -->
 
IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree: hooks can be easily configured and are automatically run in CI.

