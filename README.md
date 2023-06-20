# Flake Template for Haskell Projects

IOGX is a flake template that facilitates the development of Haskell projects at IOG.

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file stubs.

You will fill the stubs while leaving your [`flake.nix`](./template/flake.nix) largely untouched.

IOGX will populate your [`flake.nix`](./template/flake.nix) outputs based on the contents of the [`nix`](./template/nix) folder.

# Documentation

Documentation is found in the [`MANUAL.md`](./MANUAL.md).

# Features

### Support for Multiple GHCs 

  Define a set of desired GHC versions and get a `devShell` for each that comes with a complete haskell toolchain. Your `packages` will include all your project's components, nested by compiler name. Similarly your `apps` will contain the executables, testsuites and benchmarks. Your `hydraJobs` will build your project against each compiler. A version built with profiling enabled is avaialble for each component out of the box.

### Development Shells
  
  Each `devShell` comes with a complete haskell toolchain. Upon entering the shell you will be presented with a menu of available tools and commands, which include a couple of useful scripts to list your project's nix derivations and CI jobs. It's trivial to extend the shell with new packages and custom scripts, environment variables and hooks.

### Hydra Jobset
    
  Your `hydraJobs` will include every haskell component in your project, and CI will run your testsuites. You can easily exclude certain jobs, disable profiled builds, or select which components are built by which compilers.

### Formatters
 
  IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree. You can configure existing hooks and add new formatters and tools. The hooks are automatically run in CI, unless explicitly disabled.

### Read The Docs

  If you project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and add the relevant derivations to CI.

# Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Changelog Management
- Broken Link Detection 
