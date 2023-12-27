# IOGX — Flake Templates for Your Project <!-- omit in toc -->

- [1. Introduction](#1-introduction)
- [2. Features](#2-features)
- [3. API Reference](#3-api-reference)
- [4. Future Work](#4-future-work)

# 1. Introduction 

IOGX is a Nix library of functions and templates for structuring your Nix code and comes with a number of common DevX facilities to help develop your project.

Make sure that you have [installed and configured](./doc/nix-setup-guide.md) nix on your system.

To get started run: 
```bash
# For Haskell Projects
nix flake init --template github:input-output-hk/iogx#haskell

# For Other Projects
nix flake init --template github:input-output-hk/iogx#vanilla
```

These will generates a `flake.nix` and a `nix` folder in your repository root.

You may now move on to the [API Reference](./doc/api.md).

# 2. Features

### GHC Build Matrices <!-- omit in toc -->

Define a set of GHC configurations for your Haskell project using `haskell.nix`'s flake variants, and for each variant you will get `devShells`, `packages`, `apps`, `checks` and `hydraJobs`. 

### Extensible Development Shells <!-- omit in toc -->
  
`devShells` come with an optional and complete Haskell toolchain, and they can be easily extended with new packages, custom scripts, environment variables and hooks.

### Automatic Hydra Jobset <!-- omit in toc -->
    
By default your `hydraJobs` will include every component in your Haskell project, and your test suites will run in CI. 

### Easy Code Formatting <!-- omit in toc -->
 
IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree: hooks can be easily configured and are automatically run in CI.

### Read The Docs Support <!-- omit in toc -->

If your project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and will add the relevant derivations to CI.

# 3. API Reference 

The `flake.nix` file and all library functions are documented in the [API Reference](./doc/api.md).

# 4. Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Broken Link Detection 
- Option to exclude specific jobs from the `required` aggregated job.

