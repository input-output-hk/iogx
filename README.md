# IOGX — Flake Template for Haskell Projects at IOG <!-- omit in toc -->

nix -> Nix 
IOGX -> `IOGX` 
haskell -> Haskell 

- [1. Introduction](#1-introduction)
- [2. Features](#2-features)
- [3. API Reference](#3-api-reference)
  - [3.1. `flake.nix`](#31-flakenix)
    - [3.1.1. `description`](#311-description)
    - [3.1.2. `inputs`](#312-inputs)
    - [3.1.3. `outputs`](#313-outputs)
    - [3.1.4. `nixConfig`](#314-nixconfig)
  - [3.2. `nix/iogx-config.nix`](#32-nixiogx-confignix)
    - [3.2.1. `repoRoot`](#321-reporoot)
    - [3.2.2. `systems`](#322-systems)
    - [3.2.3. `haskellCompilers`](#323-haskellcompilers)
    - [3.2.4. `defaultHaskellCompiler`](#324-defaulthaskellcompiler)
    - [3.2.5. `shouldCrossCompile`](#325-shouldcrosscompile)
  - [3.3. `nix/haskell-project.nix`](#33-nixhaskell-projectnix)
    - [3.3.1. `inputs`](#331-inputs)
    - [3.3.2. `inputs'`](#332-inputs)
    - [3.3.3. `pkgs`](#333-pkgs)
    - [3.3.4. `meta`](#334-meta)
    - [3.3.5. `cabalProjectLocal`](#335-cabalprojectlocal)
    - [3.3.6. `sha256map`](#336-sha256map)
    - [3.3.7. `shellWithHoogle`](#337-shellwithhoogle)
    - [3.3.8. `modules`](#338-modules)
  - [3.4. `nix/shell.nix`](#34-nixshellnix)
    - [3.4.1. `inputs`](#341-inputs)
    - [3.4.2. `inputs'`](#342-inputs)
    - [3.4.3. `pkgs'`](#343-pkgs)
    - [3.4.4. `project`](#344-project)
    - [3.4.5. `name`](#345-name)
    - [3.4.6. `prompt`](#346-prompt)
    - [3.4.7. `welcomeMessage`](#347-welcomemessage)
    - [3.4.8. `packages`](#348-packages)
    - [3.4.9. `scripts`](#349-scripts)
    - [3.4.10. `env`](#3410-env)
    - [3.4.11. `enterShell`](#3411-entershell)
  - [3.5. `nix/per-system-outputs.nix`](#35-nixper-system-outputsnix)
    - [3.5.1. `inputs`](#351-inputs)
    - [3.5.2. `inputs'`](#352-inputs)
    - [3.5.3. `pkgs`](#353-pkgs)
    - [3.5.4. `projects`](#354-projects)
  - [3.6. `nix/top-level-outputs.nix`](#36-nixtop-level-outputsnix)
    - [3.6.1. `inputs'`](#361-inputs)
  - [3.7. `nix/read-the-docs.nix`](#37-nixread-the-docsnix)
  - [3.8. `nix/pre-commit-check.nix`](#38-nixpre-commit-checknix)
    - [3.8.1. `inputs`](#381-inputs)
    - [3.8.2. `inputs'`](#382-inputs)
    - [3.8.3. `pkgs`](#383-pkgs)
    - [3.8.4. `project`](#384-project)
    - [3.8.5. `enable`](#385-enable)
    - [3.8.6. `extraOptions`](#386-extraoptions)
  - [3.9. `nix/hydra-jobs.nix`](#39-nixhydra-jobsnix)
    - [3.9.1. `inputs`](#391-inputs)
    - [3.9.2. `inputs'`](#392-inputs)
    - [3.9.3. `pkgs`](#393-pkgs)
    - [3.9.4. `includedPaths`](#394-includedpaths)
    - [3.9.5. `excludedPaths`](#395-excludedpaths)
    - [3.9.6. `includeProfiledBuilds`](#396-includeprofiledbuilds)
    - [3.9.7. `includePreCommitCheck`](#397-includeprecommitcheck)
    - [3.9.8. `extraJobs`](#398-extrajobs)
  - [3.10. Flake Outputs Format](#310-flake-outputs-format)
- [4. Future Work](#4-future-work)

# 1. Introduction 

`IOGX` is a flake template that facilitates the development of Haskell projects at IOG.

_The vision is to provide a JSON-like, declarative interface to Nix, so that even those developers unfamiliar with the language may independently maintain and add to the Nix sources with minimal effort._

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file templates.

These files constitute IOGX's *filesystem-based* API.

You will fill in the templates in [`nix`](./template/nix) while leaving [`flake.nix`](./template/flake.nix) largely untouched.

**`IOGX` will populate your [flake outputs](#310-flake-outputs-format) based on the contents of the [`nix`](./template/nix) folder.**

You may now move on to the [API Reference](#3-api-reference).

# 2. Features

## GHC Build Matrices <!-- omit in toc -->

Define a set of GHC versions and for each version you will get `devShells`, `packages`, `apps`, `checks` and `hydraJobs`, which include profiled builds as well as builds cross-compiled for Windows. 

## Extensible Development Shells <!-- omit in toc -->
  
Each `devShell` comes with a complete Haskell toolchain, and it can be easily extended with new packages, custom scripts, environment variables and hooks.

## Automatic Hydra Jobset <!-- omit in toc -->
    
By default your `hydraJobs` will include every haskell component in your project, and your test suites will be run in CI. Derivations can be declaratively included or excluded from the final jobset.

## Easy Code Formatting <!-- omit in toc -->
 
IOGX uses [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix) to format your source tree: hooks can be easily configured and are automatically run in CI, unless explicitly disabled.

## Read The Docs Support <!-- omit in toc -->

If you project needs a [Read The Docs](https://readthedocs.org) site then IOGX will include the necessary tools and scripts, and will add the relevant derivations to CI.

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

---

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

### 3.1.1. `description`

Arbitrary description for the flake. 

This string is displayed when running `nix flake info` and other flake commands. 

It can be a short title for your project. 

### 3.1.2. `inputs`

Your flake *must* define `iogx` among its inputs. 

In turn, `IOGX` manages the following inputs for you: [CHaP](https://github.com/input-output-hk/cardano-haskell-packages), [flake-utils](https://github.com/numtide/flake-utils), [haskell.nix](https://github.com/input-output-hk/haskell.nix), [nixpkgs](https://github.com/NixOS/nixpkgs), [hackage.nix](https://github.com/input-output-hk/hackage.nix), [iohk-nix](https://github.com/input-output-hk/iohk-nix), [sphinxcontrib-haddock](https://github.com/michaelpj/sphinxcontrib-haddock), [pre-commit-hooks-nix](https://github.com/cachix/pre-commit-hooks.nix), [haskell-language-server](https://github.com/haskell/haskell-language-server), [nosys](https://github.com/divnix/nosys). 

You must *not* add these "implicit" inputs again, or you will get an error message. 

Keeping `IOGX` up-to-date implies always having the latest versions of these inputs.

However it is inevitable that, on occasion, you will want to use a different version of some of the implicit inputs, for example because `IOGX` has not been updated, or because you need to test against a specific branch.

For example, if you need a newer version of `hackage.nix`, you may do the following:
```nix 
inputs = {
  iogx.url = "github:inputs-output-hk/iogx";
  iogx.inputs.hackage.follows = "hackage";
  hackage = {
    url = "github:input-output-hk/hackage.nix";
    flake = false;
  };
};
```

It is of course possible to add other inputs (not already managed by IOGX) in the normal way. 

For example, to add `nix2container` and `cardano-world`:

```nix
inputs = {
  iogx.url = "github:inputs-output-hk/iogx";
  n2c.url = "github:nlewo/nix2container";
  cardano-world.url = "github:input-output-hk/cardano-world";
};
```
Note that IOGX will merge (union) its implicit inputs and the new inputs (`n2c`, `cardano-world`) into a single attrset, which will simply be called `inputs` in the API, and will be available to you as a function parameter.

In conclusion, the `inputs` parameter will contain both IOGX inputs and yours.

### 3.1.3. `outputs`

This line is boilerplate and should not be changed. 

IOGX hosts its main `mkFlake` function in the `lib` top-level attribute. 

There are other functions in `lib`, but they are not needed to use IOGX and will be documented later.

Note that the call to `mkFlake` must take a second argument (`./.`), but this restriction will be lifted soon.

As stated in the [Introduction](#1-introduction), your final [flake outputs](#310-flake-outputs-format) are based on the contents of the [`nix`](./template/nix) folder.

### 3.1.4. `nixConfig`

Unless you know what you are doing, you should not change `nixConfig`.

You could always add new `extra-substituters` and `extra-trusted-public-keys`, but do not delete the existing ones, or you won't have access to IOG caches. 

For the caches to work properly, it is sufficient that the following two lines are included in your `/etc/nix/nix.conf`:
```txt
trusted-users = $USER
experimental-features = nix-command flakes
```
Replace `$USER` with the result of running `whoami`. 

You may need to reload the nix daemon on Darwin:
```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```
Leave `allow-import-from-derivation` set to `true` for `haskell.nix` for work correctly.

---

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

### 3.2.1. `repoRoot` 

A Nix path to an existing folder containing the `cabal.project` file.

In future versions this field will be removed and it will default to the repository top-level directory, but until then it must be explicitly set (usually to `../.`).

### 3.2.2. `systems`

The non-empty list of systems against which your project can be built. 

These are standard Nix values found in `pkgs.stdenv.system`.

This field is required.

### 3.2.3. `haskellCompilers`

The non-empty list of GHC versions that can build your project. 

Currently two GHC versions are supported and provided by IOGX: `ghc8107` and `ghc927`.

This field affects your final [flake outputs format](#310-flake-outputs-format).

This field is required.

### 3.2.4. `defaultHaskellCompiler`

Only one compiler at a time can be visible in the `$PATH` and be available in the shell.

When calling `nix develop`, the `defaultHaskellCompiler` will be selected. 

To enter a different shell, with a different compiler, refer to the [flake outputs format](#310-flake-outputs-format). 

This field is optional and defaults to the first (leftmost)  compiler in `haskellCompilers`.

### 3.2.5. `shouldCrossCompile`

Cross-compilation on Windows is available via `mingwW64` on `x86_64-linux` only. 

When set to `true` this field affects your final [flake outputs](#310-flake-outputs-format).

If you project cannot be cross-compiled then set this field to `false`. 

This field is optional and defaults to `true`.

---

## 3.3. `nix/haskell-project.nix`

This file describes your Haskell project and will be evaluated and used internally to call `haskell.nix:cabalProject'`.

This file will be evaluated once for each element in your GHC build matrix: if your [`haskellCompilers`](#323-haskellcompilers) has 2 elements, and if [`shouldCrossCompile`](#325-shouldcrosscompile) is set to `true`, then this file will be called 8 times (taking into account profiled builds).

Needless to say: due to the lazy nature of Nix there will be no wasteful evaluations.

This file is actually optional and will default to an empty project.

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
  modules = {}; 
}
```

### 3.3.1. `inputs`

The [inputs from iogx](#312-inputs) merged with the inputs defined in your flake. 

You will also find the `self` attribute here (`inputs.self`).

Note that these inputs have been de-systemized against the current system.

This means that you can use the following syntax:
```nix
inputs.n2c.packages.nix2container
```
As opposed to:
```nix 
inputs.n2c.packages.x86_64-darwin.nix2container
```

In general, you don't want to deal with `system` explicitly, but if you must, you can use [`inputs'`](#332-inputs) instead (note the prime `'` sign).

### 3.3.2. `inputs'`

The [inputs from iogx](#312-inputs) merged with the inputs defined in your flake. 

You will also find the `self` attribute (`inputs.self`).

Note that, in contrast to [`inputs`](#331-inputs) above, these inputs have *not* been de-systemized: they are the original merged inputs from `IOGX` and your `flake.nix`. 

This means that you must always specify the system, as in the following example:    
```nix
inputs.n2c.packages.x86_64-darwin.nix2container
```

You may want to use this in case you need a Nix value (including a derivation) which is only available on one system, but which can be used safely in the context of another system. 

Instances of this are rare: in general you want to deal with [`inputs`](#331-inputs).

The `inputs/inputs'` notation has been stolen from [flake-parts](https://flake.parts).

### 3.3.3. `pkgs`

A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your configured [`systems`](#322-systems), and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

A `nixpkgs` is also available at `inputs.nixpkgs.legacyPackages` or `inputs'.nixpkgs.legacyPackages.${pkgs.stdenv.system}` but those should *not* be used because they don't have the required overlays.

You may reference `pkgs` freely to get to the legacy packages or functions from `pkgs.lib`.

### 3.3.4. `meta`

IOGX will call `haskell.nix.cabalProject'` for each of your configured [`haskellCompilers`](#323-haskellcompilers), with/without cross-compiling according to [`shouldCrossCompile`](#325-shouldcrosscompile), and with and without profiling enabled.

The `meta` field contains that information: `haskellCompiler` tells you the current compiler, `enableProfiling` tells you whether Haskell library and executable profiling will be enabled, `enableCross` tells you whether cross compilation is available, while `enableHaddock` is currently always set to `false` (but this will change in future versions). 

With the exception of `enableHaddock`, which is used in some repositories to defer plutus plugin errors, the other `meta` fields are unlikely to be needed.

### 3.3.5. `cabalProjectLocal`

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty string.

TODO link to haskell.nix docs.

### 3.3.6. `sha256map` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty attrset.

TODO link to haskell.nix docs.

### 3.3.7. `shellWithHoogle` 

Whether to include a Hoogle database in the development shell.

This field will be passed directly to `haskell.nix:cabalProject'` as `shell.withHoogle`.

It is recommended to leave this field to `false`, otherwise the entire Haskell dependency tree will need to be built with Haddock enabled.

This field is optional and defaults to `false`.

TODO link to haskell.nix docs.

### 3.3.8. `modules` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty list, but realistically it should have a value.

TODO link to haskell.nix docs.

---

## 3.4. `nix/shell.nix`

Each `haskell.nix` project produced in [haskell-project.nix](#33-nixhaskell-projectnix) comes with a shell that can be configured in this file.

The function parameters are similar to those in `haskell-project.nix`, but instead of `meta`  we have `project`.

If this file does not exist, then the shells will not be customized, but will still be available via `nix develop`.

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

### 3.4.1. `inputs`

See [`inputs`](#331-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.4.2. `inputs'`

See [`inputs`](#332-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.4.3. `pkgs'`

See [`pkgs`](#333-pkgs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.4.4. `project`

This is the very value returned by `haskell.nix:cabalProject'`, which has been augmented with the relevant [`meta`](#334-meta) field in [`haskell-project.nix`](#33-nixhaskell-projectnix).

Below your will find an example of how to use `hsPkgs` and `meta`.

### 3.4.5. `name`

This field will be used as the shell's derivation name and it will also be used to fill in the default values for [`prompt`](#346-prompt) and [`welcomeMessage`](#347-welcomemessage).

This field is optional and defaults to `nix-shell`.

### 3.4.6. `prompt`

Terminal prompt, i.e. the value of the `PS1` environment variable. 

You can use ANSI color escape sequences to customize your prompt, but you'll need to double-escape the left slashes because `prompt` is a nix string that will be embedded in a bash string.

For example, if you would normally do this in bash:
```bash
export PS1="\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] "
```
Then you need to do this in `shell.nix`:
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
This field is optional and defaults to the familiar green `nix-shell` prompt.

### 3.4.7. `welcomeMessage`

When entering the shell, this welcome message will be printed.

The same caveat about escaping back slashes in [`prompt`](#346-prompt) applies here.

This field is optional and defaults to a simple welcome message using the [`name`](#345-name) field.

### 3.4.8. `packages`

You can add anything you want here, so long as it's a derivation with executables in the `/bin` folder. 

What you put here ends up in your `$PATH` (basically the `buildInputs` in `mkDerivation`).

For example,
```nix
packages = [
  pkgs.hello 
  pkgs.curl 
  pkgs.sqlite3 
  pkgs.nodePackages.yo
];
```

This field is optional and defaults to the empty list. 

Here you could use `hsPkgs` to obtain some useful binaries:
```nix
packages = [
  project.hsPkgs.cardano-cli.components.exes.cardano-cli
  project.hsPkgs.cardano-node.components.exes.cardano-node
];
```

Be careful not to reference your project's own haskell packages via `hsPkgs`. 

If you do, then `nix develop` will build your project every time you enter the shell, and it will fail to do so if there are Haskell compiler errors.

### 3.4.9. `scripts`

Custom scripts for your shell, for example:

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
    enable = true;
  };

  waz.exec = ''
    echo "I don't have a group!"
  '';
};
``` 
`scripts` is an attrset where each attribute name is the script name each the attribute value is an attrset `{ exec, description, enabled, group }`.

The attribute names (`foobar` and `waz` in the example above) will be available in your shell as commands under the same name.

The `description` field is an optional string that will appear next to the script name. 

The `exec` field is a required, non-empty string: it is the bash code to be executed when the script is run.

The `group` field is an optional string that will be used group scripts together so that they look prettier and more organized when printed. 

The `enabled` field is an optional boolean that defaults to `true`, and can be used to include scripts conditionally, for example:
```nix 
foobar = { 
  exec = ''
    echo "I only run on Linux!"
  '';
  enabled = pkgs.stdenv.hostPlatform.isLinux;
};
```

Each shell comes with several useful scripts gathered under the `group` named `iogx`.

### 3.4.10. `env`

Custom environment variables. 

```nix
env = {
  PGUSER = "postgres";

  THE_ANSWER = 42;
};
``` 

Each attribute name-value pair defines an environment variable.

Considering the example above, the following bash code will be executed every time you enter the shell:

```bash 
export PGUSER="postgres"
export THE_ANSWER="42"
```

### 3.4.11. `enterShell`
Standard nix `shellHook`, to be executed every time you enter the shell.

```nix
enterShell = ''
  # Bash code to be executed when you enter the shell.
  echo "I'm inside the shell!"
'';
```

---

## 3.5. `nix/per-system-outputs.nix`

Any custom flake outputs, anything at all, per system.

This is where you define extra `packages`, `checks`, `apps` as well as any non-standard flake output like `nomadTasks`, `operables`, or `foobar`.

Remember that you can access these using `self` from `inputs` or `inputs'`, for example:
```nix 
inputs.self.nomadTasks.marlowe-chain-indexer
inputs'.self.nomadTasks.x86_64-linux.marlowe-chain-indexer
```

These outputs will be merged with the ones generated by IOGX, and an error will be thrown in case of a name clash.

You must *not* define `hydraJobs`, `ciJobs` nor `devShells` here.

Contrary to [`shell.nix`](#34-nixshellnix) and [`haskell-project.nix`](#33-nixhaskell-projectnix), which are evaluated several times against a configuration matrix, `per-system-outputs` is only evaluated once.

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

### 3.5.1. `inputs`

See [`inputs`](#331-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.5.2. `inputs'`

See [`inputs`](#332-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.5.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.5.4. `projects`

The `projects` parameter is an attrset containing all the projects in the build matrix. 

Refer to the [`project`](#344-project) field in [`shell.nix`](#34-nixshellnix) for more information.

Each project has an attribute name which describes the current build configuration.

For example, in a configuration with two [`haskellCompilers`](#323-haskellcompilers) and [`shouldCrossCompile`](#325-shouldcrosscompile) set to `true`, we would have:

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

---

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

This is where you may define library functions or Nix values that are pure or `system`-independent.

An error is thrown in case of a name clash with existing top-level output groups (e.g. `packages`, `devShells`).

Because these are system-independent outputs, you do not have access to the de-systemized `inputs` nor to `pkgs`.

Only in this file is it appropriate, if needed, to reach for `nixpkgs` like so:
```nix
pkgs = inputs'.nixpkgs.legacyPackages.${system};
lib = inputs'.nixpkgs.lib;
```

These top-level outputs are available everywhere else and equivalently via `inputs` and `inputs'`:
```nix
{ inputs, inputs', ... }:

let x = inputs.self.lib.f inputs'.self.networks.prod; in { };
``` 

### 3.6.1. `inputs'`

See [`inputs`](#332-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

---

## 3.7. `nix/read-the-docs.nix`

TODO 

---

## 3.8. `nix/pre-commit-check.nix`

```nix
{ inputs, inputs', pkgs, project }:
{
  cabal-fmt.enable = false;
  cabal-fmt.extraOptions = "";

  stylish-haskell.enable = false;
  stylish-haskell.extraOptions = "";

  shellcheck.enable = false;
  shellcheck.extraOptions = "";

  prettier.enable = false;
  prettier.extraOptions = "";

  editorconfig-checker.enable = false;
  editorconfig-checker.extraOptions = "";

  nixpkgs-fmt.enable = false;
  nixpkgs-fmt.extraOptions = "";

  png-optimization.enable = false;
  png-optimization.extraOptions = "";

  fourmolu.enable = false;
  fourmolu.extraOptions = "";

  hlint.enable = false;
  hlint.extraOptions = "";

  hindent.enable = false;
  hindent.extraOptions = "";
}
```

Configuration for code formatters and linters.

These are fed to [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix), which is run whenever you `git commit`.

The `pre-commit` executable is also available in your shell.

Currently 10 tools are available, and they are all disabled by default.

If this file is missing, then no hooks will be run.

### 3.8.1. `inputs`

See [`inputs`](#331-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.8.2. `inputs'`

See [`inputs`](#332-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.8.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.8.4. `project`

See [`project`](#344-project) from [`shell.nix`](#34-nixshellnix).

### 3.8.5. `enable` 

It is sufficient to set the `enable` flag to `true` to make the tool active.

When enabled, some tools expect to find a configuration file in the root of the repository, and may fail otherwise:

| Tool Name | Config File | 
| --------- | ----------- |
| `stylish-haskell` | `.stylish-haskell.yaml` |
| `editorconfig-checker` | `.editorconfig` |
| `fourmolu` | `fourmolu.yaml` (note the missing dot `.`) |
| `hlint` | `.hlint.yaml` |
| `hindent` | `.hindent.yaml` |

Currently there is no way to change the location nor the name of these configuration files.

Each tool knows which file extensions to look for, which files to ignore, and how to modify the files in-place, if possible.

### 3.8.6. `extraOptions` 

You can *append* additional options to a tool's command by setting the `extraOptions` field.

For example:

```nix
{
  cabal-fmt.enable = true;
  cabal-fmt.extraOptions = "--no-tabular";

  fourmolu.enable = false;
  fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
}
```

---

## 3.9. `nix/hydra-jobs.nix`

```nix
{ inputs, inputs', pkgs }:
{
  includedPaths = [];

  excludedPaths = []

  includeProfiledBuilds = false;
  
  includePreCommitCheck = false;

  extraJobs = {};
}
```

### 3.9.1. `inputs`

See [`inputs`](#331-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.9.2. `inputs'`

See [`inputs'`](#332-inputs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.9.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`haskell-project.nix`](#33-nixhaskell-projectnix).

### 3.9.4. `includedPaths`

This is a list of *strings*, representing attribute *paths* in your final flake outputs (i.e. paths in `inputs.self`).

These paths will populate `hydraJobs`.

Read the [flake outputs format](#310-flake-outputs-format) to learn which paths are available.

In general, you will want to include `packages`, `devShells` and `apps` here, together with any non-standard sets of derivations defined in your [`per-system-outputs.nix`](#35-nixper-system-outputsnix).

This is a good starting point:
```nix
includedPaths = 
[
  "packages"
  "devShells"
  "checks"

  "foobar.nested.package-baz"
]
```
Behind the scenes, this will produce a `hydraJobs` like so:
```nix
{
  packages = inputs.self.packages;
  devShells = inputs.self.devShells;
  checks = inputs.self.checks;

  foobar = {
    nested = {
      package-baz = inputs.self.foobar.nested.package-baz;
    };
  };
}
```

### 3.9.5. `excludedPaths`

After populating `hydraJobs` with [`includedPaths`](#includedpaths), the paths listed in `excludedPaths` will be *removed* from the final `hydraJobs`. 

This is a good place to exclude derivations or entire attrsets of derivations based on the current system.

Suppose that you have this [`per-system-outputs.nix`](#35-nixper-system-outputsnix):
```nix
{
  packages.baz = {
    foo = {
      broken = null;
      broken-on-linux = null;
    }
    bar = {
      working = null;
      broken-on-darwin = null;
    };
  };
};
```
You could have this setup:
```nix
{
  includedPaths = [
    "packages"
  ];

  excludedPaths = [
    "packages.baz.foo.broken"
  ] 
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux 
  [
    "packages.baz.foo.broken-on-darwin"
  ] 
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin 
  [
    "packages.baz.foo.broken-on-linux"
  ];
}
```

### 3.9.6. `includeProfiledBuilds` 

This is a shortcut in include or exclude profiled builds in `hydraJobs`.

This field is optional and defaults to `false`.

If set to `true`, the following list will be appended to `includedPaths`, otherwise it will appended to `excludedPaths`:
```nix
[
  "packages.ghc8107-profiled"
  "packages.ghc8107-windows-profiled"

  "devShells.ghc8107-profiled"
  "devShells.ghc8107-windows-profiled"

  "checks.ghc8107-profiled"
  "checks.ghc8107-windows-profiled"
]
```

### 3.9.7. `includePreCommitCheck`


### 3.9.8. `extraJobs`

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
