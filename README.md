# Flake Template for Haskell Projects

IOGX is a flake template that facilitates the development of Haskell projects at IOG.

To get started run: 
```
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file stubs.

You will fill the stubs while leaving your [`flake.nix`](./template/flake.nix) largely untouched.

IOGX will populate your [`flake.nix`](./template/flake.nix) outputs based on the contents of the [`nix`](./template/nix) folder.

## Documentation

Documentation is found in the [`MANUAL.md`](./MANUAL.md).

## Features

### Support for Multiple GHCs 

  You can declare a set of supported GHC versions. You will get a `devShell` for each with a complete haskell toolchain. Your `packages` will include all your haskell project's components prefixed by the compiler name. Similary your `apps` will contain the executables, testsuites and benchmarks. Your `hydraJobs` will build your project against each compiler. Finally, a profiled version will also be avaialble for each component.

### Development Shells
  
  Each `devShell` comes with a complete haskell toolchain. Upon entering the shell you will be presented with a menu of available commands, which includes a couple of useful scripts to list your project's nix derivations and CI jobs. It's trivial to extend the shell with new packages and custom scripts, env vars and hooks.

### Hydra Jobset
    
  Your `hydraJobs` will include every haskell component in your project, and CI will run your testsuites. You can exclude certain jobs, disabled profiled builds, or select which components are built by which compilers. The jobset can be easily extended with additional derivations.

### Formatters
 
  IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree. You can configure existing hooks and add new formatters and tools. The hooks are automatically run in CI, unless explicitly disabled.

### Read The Docs

  If you project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and add the relevant derivations to CI.

### Custom Outputs
  
  It's easy to define additional flake outputs and include them in your `hydraJobs`. Your outputs will be merged with the outputs produced by IOGX, and a warning will be issued in case of a name clash. 

## Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Changelog Management
- Broken Link Detection 
