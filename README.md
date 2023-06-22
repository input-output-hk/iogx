# Table of Contents <!-- omit in toc -->

- [1. Introduction](#1-introduction)
- [2. Features](#2-features)
  - [2.1. GHC Build Matrices](#21-ghc-build-matrices)
  - [2.2. Extensible Development Shells](#22-extensible-development-shells)
  - [2.3. Automatic Hydra Jobset](#23-automatic-hydra-jobset)
  - [2.4. Simple Formatters Integration](#24-simple-formatters-integration)
  - [2.5. Read The Docs Support](#25-read-the-docs-support)
- [3. API Reference](#3-api-reference)
  - [3.1. `flake.nix`](#31-flakenix)
      - [3.1.0.1. **`description`**](#3101-description)
      - [3.1.0.2. **`inputs`**](#3102-inputs)
      - [3.1.0.3. **`outputs`**](#3103-outputs)
      - [3.1.0.4. **`nixConfig`**](#3104-nixconfig)
  - [3.2. `nix/iogx-config.nix`](#32-nixiogx-confignix)
      - [3.2.0.1. **`repoRoot`**](#3201-reporoot)
      - [3.2.0.2. **`systems`**](#3202-systems)
      - [3.2.0.3. **`haskellCompilers`**](#3203-haskellcompilers)
      - [3.2.0.4. **`defaultHaskellCompiler`**](#3204-defaulthaskellcompiler)
      - [3.2.0.5. **`shouldCrossCompile`**](#3205-shouldcrosscompile)
  - [3.3. `nix/haskell-project.nix`](#33-nixhaskell-projectnix)
      - [3.3.0.1. **`inputs`**](#3301-inputs)
      - [3.3.0.2. **`inputs'`**](#3302-inputs)
      - [**`pkgs`**](#pkgs)
      - [**`meta`**](#meta)
      - [**`cabalProjectLocal`**](#cabalprojectlocal)
      - [**`sha256map`**](#sha256map)
      - [**`shellWithHoogle`**](#shellwithhoogle)
      - [**`packages`**](#packages)
  - [3.4. `nix/shell.nix`](#34-nixshellnix)
      - [**`inputs`**](#inputs)
      - [**`inputs'`**](#inputs-1)
      - [**`pkgs'`**](#pkgs-1)
      - [**`project`**](#project)
      - [**`name`**](#name)
      - [**`prompt`**](#prompt)
      - [**`welcomeMessage`**](#welcomemessage)
      - [**`packages`**](#packages-1)
      - [**`scripts`**](#scripts)
  - [3.5. `nix/per-system-outputs.nix`](#35-nixper-system-outputsnix)
  - [3.6. `nix/top-level-outputs.nix`](#36-nixtop-level-outputsnix)
  - [3.7. `nix/read-the-docs.nix`](#37-nixread-the-docsnix)
  - [3.8. `nix/pre-commit-check.nix`](#38-nixpre-commit-checknix)
  - [3.9. `nix/hydra-jobs.nix`](#39-nixhydra-jobsnix)
  - [3.10. Flake Outputs Format](#310-flake-outputs-format)
- [4. Future Work](#4-future-work)

# 1. Introduction 

`IOGX` is a flake template that facilitates the development of Haskell projects at IOG.

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file templates.

These files constitute IOGX's *filesystem-based* API.

You will fill the file templates in [`nix`](./template/nix) while leaving [`flake.nix`](./template/flake.nix) largely untouched.

**`IOGX` will populate your [`flake.nix`](./template/flake.nix) outputs based on the contents of the [`nix`](./template/nix) folder.**

You may now move onto the [API Reference](#api-reference).

# 2. Features

## 2.1. GHC Build Matrices

Define a set of GHC versions and get a set of `devShells`, `packages`, `apps`, `checks` and `hydraJobs` for each, which include profiled build as well as builds cross-compiled on Windows. 

## 2.2. Extensible Development Shells
  
Each `devShell` comes with a complete haskell toolchain, and it can be easily extended with new packages, custom scripts, environment variables and hooks.

## 2.3. Automatic Hydra Jobset
    
By default your `hydraJobs` will include every haskell component in your project, and CI will run your testsuites. Derivations can be declaratively included or excluded from the final jobset.

## 2.4. Simple Formatters Integration
 
IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree. The hooks can be easily configured and are automatically run in CI, unless explicitly disabled.

## 2.5. Read The Docs Support

If you project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and add the relevant derivations to CI.

# 3. API Reference


Click on the file name to jump to its reference section: 

- [`flake.nix`](#flakenix) — Standard flake, mostly boilerplate 
- [`nix/iogx-config.nix`](#nixiogx-confignix) — Entrypoint configuration for IOGX 
- [`nix/haskell-project.nix`](#nixhaskell-projectnix) — Definition of the [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project
- [`nix/shell.nix`](#nixshellnix) — Development environment shell
- [`nix/hydra-jobs.nix`](#nixhydra-jobsnix) — Jobset to be run on IOG's Hydra CI
- [`nix/per-system-outputs.nix`](#nixper-system-outputsnix) — Custom system-dependent flake outputs
- [`nix/top-level-outputs.nix`](#nixtop-level-outputsnix) — Custom system-independent flake outputs
- [`nix/read-the-docs.nix`](#nixread-the-docsnix) — Support for a [`read-the-docs`](https://readthedocs.org) site
- [`nix/pre-commit-check.nix`](#nixpre-commit-checknix) — Configurable [`pre-commit`](https://github.com/cachix/pre-commit-hooks.nix) hooks

## 3.1. `flake.nix`

This file is mostly boilerplate and should not be changed, unless you need to add new `inputs`.

```nix
{
  description = "Change the description field in ./flake.nix";

  inputs = { 
    iogx.url = "github:inputs-output-hk/iogx"; 
  };

  outputs = inputs: inputs.iogx.lib.mkFlake inputs ./.; 
 
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

#### 3.1.0.1. **`description`**

Arbitrary description for the flake. 

This string is displayed when running `nix flake info` and other flake commands. 

It should be like a short title for your project. 

#### 3.1.0.2. **`inputs`**

Your flake must define `iogx` among its inputs. 

In turn, `IOGX` manages the following inputs for you: CHaP, flake-utils, haskell.nix, nixpkgs, hackage, iohk-nix, sphinxcontrib-haddock, pre-commit-hooks-nix, haskell-language-server, nosys. 

You must *not* add those inputs again, or you will get an error message. 

`IOGX` will provide the latest versions of those inputs. 

Keeping IOGX up-to-date implies having the latest `CHaP`, `haskell.nix`, etc. 

However it is inevitable that you will want to use a different versions of the implicit inputs, for example because IOGX has not been updated yet. 

It is possible to ovveride the implicit inputs in one of two ways. 

For example, if you need a newer version of hackage, you may do the following:
```nix
inputs = {
  iogx.url = "github:zeme-iohk/iogx";
  iogx.inputs.hackage.url = "github:input-output-hk/hackage/my-special-gitrev-sha";
};
```
Or equivalently (more conventional and easier to update):
```nix 
inputs = {
  iogx.url = "github:zeme-iohk/iogx"; 
  iogx.inputs.hackage.follows = "hackage";
  hackage = {
    url = "github:input-outoput-hk/hackage.nix";
    flake = false;
  };
};
```

It is of course possible to add other inputs (different than the ones implicitely managed by IOGX) in the normal way. 

For example to add `nix2container`:

```nix
inputs = {
  iogx.url = "github:zeme-iohk/iogx"; 
  n2c.url = "github:nlewo/nix2container";
};
```
Note that IOGX will merge (union) its implicit inputs and the new imputs like (`n2c`) into a single attrset, which will be called `inputs` in the API.

#### 3.1.0.3. **`outputs`**

This line is boilerplate and should not be changed. IOGX hosts its main `mkFlake` function in the `lib` top-level attribute. There are other functions in `lib`, but they are not needed to use IOGX and will be documented at a later date TODO. You must pass the current directory `./.` but soon this requirement will be lifted.

#### 3.1.0.4. **`nixConfig`**

Unless you know what you are doing, you should not have to change `nixConfig`.

You could add new `substituters` and `trusted-public-keys`, but do not delete the existing ones, or you won't have access to IOG caches. 

Do make sure that the following two lines are included in your `/etc/nix/nix.conf`:
```txt
trusted-users = $USER
experimental-features = nix-command flakes
```
Replace `$USER` with the result of running `whoami`. 

You may need to reload the nix daemon on darwin:
```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```
Leave `allow-import-from-derivation` set to `true` for `haskell.nix` for work correctly.

## 3.2. `nix/iogx-config.nix`

This file must exist and it contains the main configuration values for your flake.

```nix
{ 
  repoRoot = ../.; 
  systems = [ "x86_64-linux" "x86_64-darwin" ]; 
  haskellCompilers = [ "ghc8107" ]; 
  defaultHaskellCompiler = "ghc8107"; 
  shouldCrossCompile = true; 
} 
```

#### 3.2.0.1. **`repoRoot`**

This must be a Nix path to an existing folder containing your `cabal.project` file.

In future versions this field will be removed and will default to the repository top-level directory, but until then it must be explicitely set to `../.`;

#### 3.2.0.2. **`systems`**

The non-empty list of systems against which your project can be built. 

These are standard Nix values found in `pkgs.stdenv.system`.

This field is required.

#### 3.2.0.3. **`haskellCompilers`**

The non-empty list of GHC versions that can build your project. 

Currently two GHC versions are supported and provided by IOGX: `ghc8107` and `ghc927`.

This field affects your final [flake outputs format](#310-flake-outputs-format).

This field is required.

#### 3.2.0.4. **`defaultHaskellCompiler`**

Only one compiler can be visibile in the `$PATH` and be available in the shell.

When calling `nix develop`, the `defaultHaskellCompiler` will be selected. 

To enter a different shell refer to the [flake outputs format](#310-flake-outputs-format). 

This field is optional and defaults to the first compiler (leftmost) in `haskellCompilers`.

#### 3.2.0.5. **`shouldCrossCompile`**

Cross-compilation on windows is done via `mingwW64` on `x86_64-linux` only. 

When set to true this field affects your final [flake outputs format](#310-flake-outputs-format).

If you project cannot be cross-compiled then set this field to `false`. 

This field is optional and defaults to `true`.

## 3.3. `nix/haskell-project.nix`

Writing this file requires a non-trivial undertanding of nix and haskell.nix and therefore it should be maintained by a nix expert or a member of `@smart-contracts-dev-empowerment`. 

This file receives useful parameters from IOGX and must return a set of values that will be used to call `haskell.nix:cabalProject'` behind the scenes. 

Note that this file will be evaluated for each [`haskellCompilers`](#3203-haskellcompilers), with/wihtout profiling and with/without cross-compiling.

Therefore, if [`haskellCompilers`](#3203-haskellcompilers) has 2 elements and if [`shouldCrossCompile`](#3205-shouldcrosscompile) is enabled, then this file will be evaluated 8 times.

Note however that due to the lazy nature of Nix there will be no wasteful evaluations.

In file is actually optional and will default to an empty project.

```nix
{ inputs 
, inputs' 
, pkgs 
, { haskellCompiler
  , enableHaddock 
  , enableProfiling 
  , enableCross 
  }@meta 
}:
{
  cabalProjectLocal = ""; 
  sha256map = {}; 
  shellWithHoogle = false; 
  packages = {}; 
}
```

#### 3.3.0.1. **`inputs`**

All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the inputs defined in your flake. 

You will also find the `self` attribute here (`inputs.self`).

Note that these inputs have been desystemized against the current system.

This means that you can use the following syntax:
```nix
inputs.n2c.packages.nix2container
```
As opposed to:
```nix 
inputs.n2c.packages.x86_64-darwin.nix2container
```

In general you don't want to deal with `system` explicitely, but if you must, you can use [`inputs'`](#3302-inputs).


#### 3.3.0.2. **`inputs'`**

All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the inputs defined in your flake. 

You will also find the `self` attribute (`inputs.self`).

Note that these inputs have *not* been desystemized, they are the original inputs from `IOGX` and your `flake.nix`. 

This means that you must always specify the system, as in the following example:    
```nix
inputs.n2c.packages.x86_64-darwin.nix2container
```

You may want to use this in case you need a nix value (incuding a derivation) which is only avaialble on one system, but which can be used safely in the context of another system. 

Instances of that are rare: in general you want to deal with `inputs`.

The `inputs` - `inputs'` notation has been stolen from `flake-parts`. TODO link

#### **`pkgs`**

A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`, and one of `iogx-config.nix:systems`) and overlaied with goodies from `haskell.nix` and `iohk-nix`. 

A `nixpkgs` is also avaialble at `inputs.nixpkgs.legacyPagckages` or `inputs'.nixpkgs.legacyPcakges.${system}` but those should never be used bacause they don't have the required ovelays.

#### **`meta`**

IOGX needs to call `haskell.nix.cabalProject'` for each compiler defined in your iogx-config:haskellCompilers TODO. 

In addition, it can build that project with profiling enabled (`enableProfiling`) and/or with cross compilation (`enableCross` and only if `shouldCrossCompile` had been set to true) while `enableHaddock` is currently always set to `false` (rationale for this coming soon).

With this in mind, we have a build matrix of 4 dimensions: `system` (implicit in `pkgs.stdenv.system`), haskellCompiler (one of `hasskellCompoilers`) `enableCross` {} and enableHaddock. This means that with the default configuration this file will be imported 2 (systems) x 1 (haskellCompilers) x 2 {enableCross true | false} x 2 { enableHaddock true | false } = 8 times.

With the exception of `enableHaddock`, the other `meta` fields are unlickely to be needed.

#### **`cabalProjectLocal`**

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty string.

TODO link to haskell.nix docs.

#### **`sha256map`** 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optonal and defaults to the empty attrset.

TODO link to haskell.nix docs.

#### **`shellWithHoogle`** 

This field will be passed directly to `haskell.nix:cabalProject'` as `shell.withHoogle`.

Whether to add a Hoogle(TODO link) database to the shell. 

It is reccomended to leave this field to `false`, otherwise the entire haskell dependency tree will need to be built with haddock enabled.

This field is optonal and defaults to false.

TODO link to haskell.nix docs.

#### **`packages`** 

This is the classic `packages` attrset in a `haskell.nix` module. 

This field is optonal and defaults to the empty attrset, but realistally it should be full and daunting.

TODO link to haskell.nix docs.

## 3.4. `nix/shell.nix`

Similarly to `haskell-project.nix` we have a shell for each element in the build matrix. 

The function parameters are similar to those in `haskell-project.nix`, but instead of `meta`  we have `project`.

This file optional, which simply means that the default shells will not be customised in any way.

```nix
{ inputs
, inputs'
, pkgs
, { meta
  , hsPkgs
  , ... 
  }@project
}:
{ 
  name = "devShell";
  prompt = "$ ";
  welcomeMessage = "devShell";

  packages = [ ];
  scripts = { };
  env = { };
  enterShell = "";
}
```

#### **`inputs`**

See inputs from haskell-project.nix 

#### **`inputs'`**

See inputs' from haskell-project.nix 

#### **`pkgs'`**

See pkgs from haskell-project.nix 

#### **`project`**

This is the very attrset returned by `haskell.nix:cabalProject'`. 

In fact, each `devShell` is built on top of a `haskell.nix` project, and here we obtain a reference to it. 

Note that `project` has been augmented with an additional field named `meta`, as seen in `haskell-project.nix`.

The `meta` attrset may be more useful here as it could be used to customize `name` `prompt` and `welcomeMessage`


#### **`name`**

This field will be used as the shell's derivation name as well it will be used to fill the default values of `prompt` and `welcomeMessage`.

This field is optional and defaults to `devShell`.

#### **`prompt`**

The value of the `PS1` evnvar. 

You can use ansii coloring to customise your prompt, but you'll need to double-escape the left slashes because this is a nix string that will be embedded in a bash
string.

So if you would normally do this in bash:
```bash
export PS1="\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] "
```
Then you need to do this in `shell.nix`
```nix
prompt = "\n\\[\\033[1;32m\\][nix-shell:\\w]\\$\\[\\033[0m\\] ";
```
You can use the `meta` field here to customize your prompt like so:
```nix
prompt = 
  let 
    ghc = meta.haskellCompiler;
    profiled = if meta.enableProfiling then "-prof" else "";
    cross = if meta.enableCross then "-x" else "";
    prefix = "foobar-${ghc}${cross}${profiled}";
  in 
    "\n\\[\\033[1;32m\\][${prefix}:\\w]\\$\\[\\033[0m\\] !;
```
This field is optional and defaults to the familiar green `nix-shell` promopt.

#### **`welcomeMessage`**

When entering the shell, this welcome message will be printed.

The same caveat about esaping back slashes in `prompt` applies here.

This field is optional and defaults to a simple welcome messaage using the `name` field.

#### **`packages`**

You can add anything you want here, so long as it's a derivation with executables in the `/bin` folder. 

What you put here ends up in your `$PATH` while inside the shell (basically the `buildInputs` in `mkDerivation`).

For example,
```nix
packages = [
  pkgs.hello 
  pkgs.curl 
  pkgs.sqlite3 
  pkgs.nodePackages.yo
];
```

This field is optional and defaults to the empty list `[]`. 

The `project` field can be used to extract some useful binaries like so:
```nix
packages = [
  project.hsPkgs.cardano-cli.components.exes.cardano-cli
  project.hsPkgs.cardano-node.components.exes.cardano-node
];
```

Be careful not to reference the project's own haskell packages in `hsPkgs`. 

If you do, then `nix develop` will build your project every time and it will fail to 
drop you into the shell if there are compiler errors.

#### **`scripts`**

Custom scripts for your shell.
```nix
scripts = {
  foobar = {
    exec = ''
      # Bash code to be executed whenever the script `foobar` is run.
      echo "Delete me from your nix/shell.nix!"
    '';
    description = ''
      You might want to delete the foobar script.
    '';
    group = "bazwaz";
    enabled = true;
  };

  waz.exec = ''
    echo "I don't have a group!"
  '';
};
``` 
`scripts` is an attrset where each attribute name is the script name, and the attribute value is an attrset `{ exec, description, enabled, group }`.
`description` is optional will appear next to the script name.
`exec` is bash code to be executed when the script is run.
`group` is optional and is used to group scripts together when printed.
`enabled` is optional, defaults to true if not set, and can be used to 
include scripts conditionally, for example:
```nix 
foobar = { 
  exec = "# Noop";
  enabled = pkgs.stdenv.system != "x86_64-darwin"; 
};
```
IOGX will include several scripts for you. One of the most important scripts is the `info` script, which will list all avaiable scripts as well as the current environemnt veriables.

`env`
Custom environment variables. For each NAME-VALUE pair in `env` the bash line:
```bash 
export NAME="VALUE"
```
will be appended to `enterShell`. 
These environment variables will be visiable inside the shell.

`enterShell`
Standard nix `shellHook`, to be executed as soon as you enter the shell.
For example
```nix
enterShell = ''
  # Bash code to be executed when you enter the shell.
  echo "I'm inside the shell"
'';
```

## 3.5. `nix/per-system-outputs.nix`

```nix
{ inputs, inputs', pkgs, projects }:
{
  packages = { };
  checks = { };
  apps = { };
  operables = { };
  oci-images = { };
  nomadTasks = { };
  foobar = { };
}
```
Any extra flake outputs, anything at all, per system (pkgs.stdenv.system)

This is where you define extra `packages`, `checks`, `apps`, etc..., or any 
non-standard flake output like `nomadTasks` or `operables`.

Remember that you can access these using `self` from `inputs` or 
 `inputs'`, for example:
```nix 
inputs.self.nomadTasks.marlowe-chain-indexer
inputs'.self.nomadTasks.x86_64-linux.marlowe-chain-indexer
```
These ouputs will be merged with the once generated by IOGX, and an error will be thrown in case of a name clash.
Remember that IOGX nests its derivation under a name comting form the current build matrix configuration.
You can use that namespace to add some of your inputs. 

Contrary to `shell.nix` and `haskell-project.nix`, which are evaluated against a configuration matrix, `per-system-outputs` is only evaludated once.
Its `inputs`, `inputs'` and `pkgs` parameters are the uusual.
The `projects` params in new and is an attreset indexed by matrix tag, and containing a `project` just like in `shell.nix`.
For example, in the standard configuration, we would have:
```nix
projects.ghc8107 = { meta, hsPkgs, ... };
projects.ghc8107-profiled = { meta, hsPkgs, ... };
projects.ghc8107-windows = { meta, hsPkgs, ... };
projects.ghc8107-windows-profiled = { meta, hsPkgs, ... };
```
In case of two haskellCompilers (for example `ghc927` we would have)
```nix
projects.ghc8107 = { meta, hsPkgs, ... };
projects.ghc8107-profiled = { meta, hsPkgs, ... };
projects.ghc8107-windows = { meta, hsPkgs, ... };
projects.ghc8107-windows-profiled = { meta, hsPkgs, ... };
projects.ghc927 = { meta, hsPkgs, ... };
projects.ghc927-profiled = { meta, hsPkgs, ... };
projects.ghc927-windows = { meta, hsPkgs, ... };
projects.ghc927-windows-profiled = { meta, hsPkgs, ... };
```

## 3.6. `nix/top-level-outputs.nix`

Top-level flake outputs, not dependent on `system`. 

```nix 
{ inputs' }:
{
  lib = {
    f = _: null;
  };

  networks = {
    prod = { };
    dev = { };
  }
}
```

An error is thrown in case of a name clash with exisiting top-level output groups (e.g. `packages`, `devShells` or user-defined).

Because these are system-independent outputs, you do not have access to the de-systemized `inputs` nor to `pkgs`.

Only in this file is it appropriate, if needed, to reach for `nixpkgs` like so:
```nix
pkgs = inputs'.nixpkgs.legacyPackages.${my-system};
lib = inputs'.nixpkgs.lib;
```

These ouputs are availalbe everywhere else and equivalently via `inputs` and `inputs'`:
```nix
{ inputs, inputs', ... }:

let x = inputs.self.lib.f inputs'.self.networks.prod; in { };
``` 

By default these outputs are not included in `hydraJobs` and therefore they are not built in CI.

They can nonetheless appear in `hydra-jobs.nix:extraJobs` and thus become part of the jobset.

## 3.7. `nix/read-the-docs.nix`

Coming soon 

## 3.8. `nix/pre-commit-check.nix`

```nix
{ inputs, inputs', pkgs, project }:
{
  cabal-fmt.enable = true;
  cabal-fmt.extraOptions = "--no-tabular";

  stylish-haskell.enable = true;
  shellcheck.enable = true;
  prettier.enable = true;
  editorconfig-checker.enable = true;
  nixpkgs-fmt.enable = true;
  png-optimization.enable = true;
  fourmolu.enable = true;
  hlint.enable = true;
  hindent.enable = true;
}
```

Configuration for arbitrary hooks to be run before committing code to git.

Currently 10 tools are avaialble and configurable, and they are all disabled by default.

It is sufficient to set the `enable` flag to `true` to make the tool available and be run before `git commit`.

Each tool knows which file extensions to look for, which files to ignore, and how to modify the files inplace, if possible.

You can *append* additional flags to a tool's command by setting the `extraOptions` field.

When enabled, the following tools expect to find a configuration file in the root of the repository, and may fail otherwise:


| Tool Name | Config File | 
| --------- | ----------- |
| `stylish-haskell` | `.stylish-haskell.yaml` |
| `editorconfig-checker` | `.editorconfig` |
| `fourmolu` | `fourmolu.yaml` |
| `hlint` | `.hlint.yaml` |
| `hindent` | `.hindent.yaml` |

Currently there is no way to change the location or the name of these configuration files.

Note that `fourmolu.yaml` does not begin with a dot (`.`).

The `inputs`, `inputs'`, `pkgs` and `project` parameters have the same structure and semantics as those in `shell.nix`.

It is very unlikely that they should be needed, but they are exposed anyway.

If `./nix/pre-commit-check.nix` is missing, or if it evaluates to an empty attrset then no hook will run.

Setting or adding unknown fields the the returned attrset causes an error.

## 3.9. `nix/hydra-jobs.nix`

```nix
{ inputs, inputs', pkgs }:
{
  excludedPaths = 
  [
    "packages.ghc8107-profiled"
    "packages.ghc8107-mingwW64-profiled"

    "devShells.ghc8107-profiled"
    "devShells.ghc8107-mingwW64-profiled"

    "checks.ghc8107-profiled"
    "checks.ghc8107-mingwW64-profiled"

    "networks"
    "nomadTasks"
    "operables"
  ] 
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux 
  [
    "devShells.ghc927"
    "devShells.ghc927-profiled"
  ];

  extraJobs = {

  };
}
```

Every available derivation will be build in CI by default.

The default Hydra jobset gathers all existing flake outputs under the `hydraJobs` top-level field, but it ignores those outputs define in `top-level-outputs.nix`.

The better way to blacklist jobs is by excluding attribute paths, potentally taking into consideration the current system.

In the example above we are excluding all profiled derivations (to save time) as well as all `networks`, `nomadTasks` and `operables` (because they may not evaluate to derivations) and we make sure not to build 

The `inputs`, `inputs'` and `pkgs` parameters have the same structure and semantics as those in `shell.nix`.
 

`excludePaths` is a list of strings, where each string is dot-separated and encodes an attribute path inside `inputs.self`. 

extra-jobs can be used to incldue top-level derivations like so:
```nix
extraJobs.top-level-buildable = inputs.self.custom-group.my-derivation;
```
This field is optional and defaults to the empty set `{}`, which means: do not add any extra job.

## 3.10. Flake Outputs Format 

Given `haskellCompilers = [ghc8107 ghc927]`

```
ghc ::= one of nix/iogx-config.nix:haskellCompilers

system ::= one of nix/iogx-config.nix:systems

compiler ::= ghc | ghc "-profiled" | ghc "-windows" | ghc "-windows-profiled"

cabalpkg ::= one of the packages in cabal.project 

compname ::= "exe" | "test" | "lib" | "sublib" 

pkgcomp ::= any component in a .cabal file 

packages ::= "packages." system "." compiler "." cabalpkg "-" compname "-" pkgcomp

apps ::= "apps." system "." compiler "." cabalpkg "-" ("exe" | "test") "-" pkgcomp

checks ::= "checks." system "." compiler "." cabalpkg "-test-" pkgcomp

devShells ::= 

hydraJobs ::= "hydraJobs."

```

# 4. Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Changelog Management
- Broken Link Detection 
