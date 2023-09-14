# IOGX — A Flake Template for Your Project <!-- omit in toc -->

- [1. Introduction](#1-introduction)
- [2. Features](#2-features)
- [3. Reference](#3-reference)
- [4. The `flake.nix` file](#4-the-flakenix-file)
  - [4.1. `description`](#41-description)
  - [4.2. `inputs`](#42-inputs)
  - [4.3. `outputs`](#43-outputs)
  - [4.4. `nixConfig`](#44-nixconfig)
- [5. Future Work](#5-future-work)

# 1. Introduction 

IOGX is a flake template that provides a skeleton for your Nix code and comes with a number of common DevX facilities to develop your project.

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) to get you started. 

You may now move on to the [Options Reference](./doc/options.md).

# 2. Features

### GHC Build Matrices <!-- omit in toc -->

Define a set of GHC versions and for each version you will get `devShells`, `packages`, `apps`, `checks` and `hydraJobs`, which include profiled builds as well as builds cross-compiled for Windows. 

### Extensible Development Shells <!-- omit in toc -->
  
Each `devShell` comes with a complete Haskell toolchain, and it can be easily extended with new packages, custom scripts, environment variables and hooks.

### Automatic Hydra Jobset <!-- omit in toc -->
    
By default your `hydraJobs` will include every Haskell component in your project, and your test suites will run in CI. 

### Easy Code Formatting <!-- omit in toc -->
 
IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree: hooks can be easily configured and are automatically run in CI'

### Read The Docs Support <!-- omit in toc -->

If you project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and will add the relevant derivations to CI.

# 3. Reference 

1. [`flake.nix`](#TODO)
   - Entrypoint for the Nix code.
2. [`inputs.iogx.lib.mkFlake`](#TODO) 
   - Makes the final flake outputs.
3. [`pkgs.lib.iogx.mkProject`](#TODO) 
   - Makes a [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project decorated with the `iogx` overlay.
4. [`pkgs.lib.iogx.mkShell`](#TODO) 
   - Makes a `devShell` with `pre-commit-check` and tools.

# 4. The `flake.nix` file

```nix
{
  description = "Change the description field in ./flake.nix";

  inputs = { 
    iogx = {
      url = "github:inputs-output-hk/iogx"; 
      inputs.hackage.follows = "hackage";
      inputs.CHaP.follows = "CHaP";
    };

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };
  };

  outputs = inputs: inputs.iogx.lib.mkFlake {
    inherit inputs;
    repoRoot = ./.;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    outputs = { repoRoot, inputs, pkgs, lib, system }: [];
  };
 
  nixConfig = { 
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = true; 
  };
}
```

## 4.1. `description`

Arbitrary description for the flake. 

This string is displayed when running `nix flake info` and other flake commands. 

It can be a short title for your project. 

## 4.2. `inputs`

Your flake *must* define `iogx` among its inputs. 

In turn, IOGX manages the following inputs for you: [CHaP](https://github.com/input-output-hk/cardano-haskell-packages), [haskell.nix](https://github.com/input-output-hk/haskell.nix), [nixpkgs](https://github.com/NixOS/nixpkgs), [hackage.nix](https://github.com/input-output-hk/hackage.nix), [iohk-nix](https://github.com/input-output-hk/iohk-nix), [sphinxcontrib-haddock](https://github.com/michaelpj/sphinxcontrib-haddock), [pre-commit-hooks-nix](https://github.com/cachix/pre-commit-hooks.nix), [haskell-language-server](https://github.com/haskell/haskell-language-server), [easy-purescript-nix](https://github.com/justinwoo/easy-purescript-nix). 

If you find that you want to use a different version of some of the implicit inputs, for instance because IOGX has not been updated, or because you need to test against a specific branch, you can use the `follows` syntax.

Note that the template `flake.nix` does this by default with `CHaP` and `hackage.nix`. 

It is of course possible to add other inputs (not already managed by IOGX) in the normal way. 

For example, to add `nix2container` and `cardano-world`:

```nix
inputs = {
  iogx.url = "github:inputs-output-hk/iogx";
  n2c.url = "github:nlewo/nix2container";
  cardano-world.url = "github:input-output-hk/cardano-world";
};
```

If you need to reference the inputs managed by IOGX in your flake, you may use this syntax:

```nix
nixpkgs = inputs.iogx.inputs.nixpkgs;
CHaP = inputs.iogx.inputs.CHaP; # Or inputs.CHaP if using `follows`
haskellNix = inputs.iogx.inputs.haskell-nix;
```

If you need to update IOGX, you can do it the normal way:

```bash
nix flake lock --update-input iogx 
```

## 4.3. `outputs`

Your flake `outputs` are produced using `inputs.iogx.lib.mkFlake`#TODO

## 4.4. `nixConfig`

Unless you know what you are doing, you should not change `nixConfig`.

You could always add new `extra-substituters` and `extra-trusted-public-keys`, but do not delete the existing ones, or you won't have access to IOG caches. 

For the caches to work properly, it is sufficient that the following two lines are included in your `/etc/nix/nix.conf`:
```txt
trusted-users = USER
experimental-features = nix-command flakes
```
Replace `USER` with the result of running `whoami`. 

You may need to reload the nix daemon on Darwin for changes to `/etc/nix/nix.conf` to take effect:
```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```
Leave `allow-import-from-derivation` set to `true` for `haskell.nix` for work correctly.

If Nix starts building `GHC` or other large artifacts that means that your caches have not been configured properly.

# 5. Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Broken Link Detection 
- Option to exclude specific jobs from the `required` aggregated job.