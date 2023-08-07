# IOGX — A Flake Template for Your Project <!-- omit in toc -->

- [1. Introduction](#1-introduction)
- [2. Features](#2-features)
- [3. API Reference](#3-api-reference)
  - [3.1. `flake.nix`](#31-flakenix)
    - [3.1.1. `description`](#311-description)
    - [3.1.2. `inputs`](#312-inputs)
    - [3.1.3. `outputs`](#313-outputs)
    - [3.1.4. `nixConfig`](#314-nixconfig)
  - [3.2. `nix/haskell.nix`](#32-nixhaskellnix)
    - [3.2.1. `inputs`](#321-inputs)
    - [3.2.2. `inputs'`](#322-inputs)
    - [3.2.3. `pkgs`](#323-pkgs)
    - [3.2.4. `supportedCompilers`](#324-supportedcompilers)
    - [3.2.5. `defaultCompiler`](#325-defaultcompiler)
    - [3.2.6. `enableCrossCompilation`](#326-enablecrosscompilation)
    - [3.2.7. `defaultChangelogPackages`](#327-defaultchangelogpackages)
  - [3.3. `nix/cabal-project.nix`](#33-nixcabal-projectnix)
    - [3.3.1. `inputs`](#331-inputs)
    - [3.3.2. `inputs'`](#332-inputs)
    - [3.3.3. `meta`](#333-meta)
    - [3.3.4. `pkgs`](#334-pkgs)
    - [3.3.5. `config`](#335-config)
    - [3.3.6. `lib`](#336-lib)
    - [3.3.7. `cabalProjectLocal`](#337-cabalprojectlocal)
    - [3.3.8. `sha256map`](#338-sha256map)
    - [3.3.9. `shellWithHoogle`](#339-shellwithhoogle)
    - [3.3.10. `modules`](#3310-modules)
    - [3.3.11. `overlays`](#3311-overlays)
  - [3.4. `nix/shell.nix`](#34-nixshellnix)
    - [3.4.1. `inputs`](#341-inputs)
    - [3.4.2. `inputs'`](#342-inputs)
    - [3.4.3. `pkgs`](#343-pkgs)
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
    - [3.6.1. `inputs`](#361-inputs)
  - [3.7. `nix/read-the-docs.nix`](#37-nixread-the-docsnix)
    - [3.7.1. `siteFolder`](#371-sitefolder)
  - [3.8. `nix/formatters.nix`](#38-nixformattersnix)
    - [3.8.1. `inputs`](#381-inputs)
    - [3.8.2. `inputs'`](#382-inputs)
    - [3.8.3. `pkgs`](#383-pkgs)
    - [3.8.4. `enable`](#384-enable)
    - [3.8.5. `extraOptions`](#385-extraoptions)
  - [3.9. `nix/ci.nix`](#39-nixcinix)
    - [3.9.1. `inputs`](#391-inputs)
    - [3.9.2. `inputs'`](#392-inputs)
    - [3.9.3. `pkgs`](#393-pkgs)
    - [3.9.4. `includedPaths`](#394-includedpaths)
    - [3.9.5. `excludedPaths`](#395-excludedpaths)
- [4. Future Work](#4-future-work)

# 1. Introduction 

IOGX is a flake template that provides a skeleton for your Nix code and comes with a number of common DevX facilities to develop your project.

_The vision is to provide a JSON-like and declarative interface to Nix, so that developers unfamiliar with the language may independently maintain and add to the Nix code with minimum effort and maximum pleasure._

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file templates.

These files constitute IOGX's *filesystem-based* API.

You will fill in the templates in the [`nix`](./template/nix) folder while leaving [`flake.nix`](./template/flake.nix) largely untouched.

**IOGX will populate your flake outputs based on the contents of the nix folder.**

If you dislike this approach, you can always opt for using inline attribute sets instead of files.

You may now move on to the [API Reference](#3-api-reference).

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

# 3. API Reference

Click on the file name to jump to its reference section.

- [`flake.nix`](#31-flakenix) — Standard flake, from where you will call [`iogx.lib.mkFlake`] 
- [`nix/haskell.nix`](#32-nixhaskellnix) — Basic configuration values for a Haskell project
- [`nix/cabal-project.nix`](#33-nixcabal-projectnix) — How to build your [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) cabal project
- [`nix/shell.nix`](#34-nixshellnix) — Development environment
- [`nix/ci.nix`](#39-nixcinix) — Jobset to be run in IOG's Hydra CI
- [`nix/per-system-outputs.nix`](#35-nixper-system-outputsnix) — Custom system-dependent flake outputs
- [`nix/top-level-outputs.nix`](#36-nixtop-level-outputsnix) — Custom system-independent flake outputs
- [`nix/read-the-docs.nix`](#37-nixread-the-docsnix) — Support for a [`read-the-docs`](https://readthedocs.org) site
- [`nix/formatters.nix`](#38-nixformattersnix) — Configurable code formatters 

## 3.1. `flake.nix`

```nix
{
  description = "Change the description field in ./flake.nix";

  inputs = { 
    iogx.url = "github:inputs-output-hk/iogx"; 
  };

  outputs = inputs: inputs.iogx.lib.mkFlake {
    inherit inputs;
    repoRoot = ./.;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    config = null;
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

### 3.1.1. `description`

Arbitrary description for the flake. 

This string is displayed when running `nix flake info` and other flake commands. 

It can be a short title for your project. 

### 3.1.2. `inputs`

Your flake *must* define `iogx` among its inputs. 

In turn, IOGX manages the following inputs for you: [CHaP](https://github.com/input-output-hk/cardano-haskell-packages), [flake-utils](https://github.com/numtide/flake-utils), [haskell.nix](https://github.com/input-output-hk/haskell.nix), [nixpkgs](https://github.com/NixOS/nixpkgs), [hackage.nix](https://github.com/input-output-hk/hackage.nix), [iohk-nix](https://github.com/input-output-hk/iohk-nix), [sphinxcontrib-haddock](https://github.com/michaelpj/sphinxcontrib-haddock), [pre-commit-hooks-nix](https://github.com/cachix/pre-commit-hooks.nix), [haskell-language-server](https://github.com/haskell/haskell-language-server), [nosys](https://github.com/divnix/nosys). 

You must *not* add these "implicit" inputs again to your `flake.nix`.

Keeping IOGX up-to-date implies always having the latest version of these inputs.

However you might find that you want to use a different version of some of the implicit inputs, for instance because IOGX has not been updated, or because you need to test against a specific branch.

For example, to use a newer version of `CHaP` and `hackage.nix`, you may do the following:

```nix 
inputs = {
  iogx.url = "github:inputs-output-hk/iogx";
  iogx.inputs.hackage-nix.follows = "hackage-nix";
  iogx.inputs.CHaP.follows = "CHaP";

  hackage-nix = {
    url = "github:input-output-hk/hackage.nix";
    flake = false;
  };

  CHaP = {
    url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
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

If you need to reference the inputs managed by IOGX in your flake, you may use this syntax:

```nix
nixpkgs = inputs.iogx.inputs.nixpkgs;
CHaP = inputs.iogx.inputs.CHaP;
hackage = inputs.iogx.inputs.hackage;
```

If you need to update IOGX, you can do it the normal way:

```bash
nix flake lock --update-input iogx 
```

### 3.1.3. `outputs`

IOGX hosts its main `mkFlake` function in the `lib` top-level attribute. 

There are other functions in `lib`, but they are not needed to use IOGX proper.

`mkFlake` behaves differently depending on whether the `config` arg is present (and not `null`).

If `config` is `null`, then IOGX expects to find a `./nix` folder inside your `repoRoot`, and will load the files inside that folder to generate the flake outputs.

Alternatively, the exact contents of the `./nix` folder may be mirrored using the `config` attribute.

In that case `repoRoot` does not have to contain the `./nix` folder, and will not make any assumption about the location of other nix files.

The `systems` field tells which systems are supported by your project, it is optional and defaults to `["x86_64-darwin" "x86_64-linux"]`.

As for the `inputs` field, you almost always want to do `inherit inputs;` like in the example above.

For example, the two following invocations of `mkFlake` are equivalent:
```nix
# (1) Using the file-system based API

# Contents of ./flake.nix 
outputs = inputs: inputs.iogx.lib.mkFlake {
  inherit inputs;
  repoRoot = ./.;
};

# Contents of ./nix/formatters.nix 
{
  cabal-fmt.enable = true;
  shellcheck.enable = true;
}

# Contents of ./nix/read-the-docs.nix
{
  siteFolder = "read-the-docs";
}

# Contents of ./nix/read-the-docs.nix
{ pkgs, ... }: 
{
  packages = [ pkgs.hello ];
}
```

```nix
# (2) Using the `config` param

outputs = inputs: inputs.iogx.lib.mkFlake {
  inherit inputs;
  repoRoot = ./.;
  config = {
    formatters = {
      cabal-fmt.enable = true;
      shellcheck.enable = true;
    };
    read-the-docs.siteFolder = "read-the-docs";
    shell = { pkgs, ... }: {
      packages = [pkgs.hello];
    };
  };
};
```

The rest of this `README.md` assumes that you are using the former, file-system based API.

However every requirement and caveat also applies to the latter `config` based API. 

### 3.1.4. `nixConfig`

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

## 3.2. `nix/haskell.nix`

```nix
{ inputs, inputs', pkgs, ... }:
{ 
  supportedCompilers = [ "ghc8107" ]; 
  defaultHaskellCompiler = "ghc8107"; 
  enableCrossCompilation = false; 
  defaultChangelogPackages = [];
} 
```

This file is optional and contains fundamental configuration values for your Haskell project.

If none of the function parameters are needed (i.e. `inputs`, `inputs'`, `pkgs`, `...`), your can omit them altogether and just define the attrset (this applies to all files inside the `./nix` folder, and the attributes inside the `config` passed to `mkFlake`, if used).

### 3.2.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.2.2. `inputs'`

See [`inputs'`](#332-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.2.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.2.4. `supportedCompilers`

The non-empty list of GHC versions that can build your project. 

Currently three GHC versions are supported and provided by IOGX: `ghc8107`, `ghc927` and `ghc928`.

This field is required.

### 3.2.5. `defaultCompiler`

Only one compiler at a time can be visible in the `$PATH` in the shell.

When calling `nix develop`, the `defaultCompiler` will be selected. 

You you want to enter a shell with a different compiler, run `list-flake-outputs` while inside any other `nix develop` shell, and you will be presented with a list of options.

This field is optional and defaults to the first (leftmost) compiler in `supportedCompilers`.

### 3.2.6. `enableCrossCompilation`

Cross-compilation on Windows is available via `mingwW64` on `x86_64-linux` only. 

If enabled, cross-compiled packages for you haskell project will be built in CI.

This field is optional and defaults to `false`.

### 3.2.7. `defaultChangelogPackages`

You can use `scriv` to manage changelogs for your Haskell project.

Type `info` while inside any `nix develop` shell to display the relevant scripts under the `changelog` tag.

Set `defaultChangelogPackages` to the list of cabal packages for which to handle changelogs by default.

For example in `plutus` this would be:
```
defaultChangelogPackages = [ 
  "plutus-core"
  "plutus-ledger-api"
  "plutus-tx"
  "plutus-tx-plugin"
  "prettyprinter-configurable"
];
```

This field is optional and defaults to the empty list `[]`.

## 3.3. `nix/cabal-project.nix`

```nix
{ inputs 
, inputs' 
, { haskellCompiler
  , enableHaddock 
  , enableProfiling 
  }@meta 
, pkgs 
, config 
, lib 
, ...
}:
{
  cabalProjectLocal = ""; 
  sha256map = { }; 
  shellWithHoogle = false; 
  modules = [ ]; 
  overlays = [ ];
}
```

This file is only used if `./nix/haskell.nix` exists, and returns the arguments that will be used to create a `haskell.nix` project. 

See `haskell.nix`'s [`cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html#cabalproject) function for details.

This file will be evaluated once for each element in your GHC build matrix: if your [`supportedCompilers`](#324-supportedcompilers) has 2 elements, then `./nix/cabal-project.nix` will be called 4 times (taking into account profiled and non-profiled builds).

This will largely affect what your final flake outputs look like. You should run `list-flake-outputs` while inside a `nix develop` shell to see what's available.

If this file does not exist then a `haskell.nix` project will still be created using default values and common heuristics.

### 3.3.1. `inputs`

Your ordinary flake [`inputs`](#312-inputs) as defined in your `flake.nix`.

You will also find the `self` attribute here (`inputs.self`).

Note that, in contrast to [`inputs'`](#332-inputs) below, these inputs have *not* been de-systemized. 

This means that you must always specify the system, as in the following example:    
```nix
inputs.n2c.packages.x86_64-darwin.nix2container
```

You may want to use this in case you need a Nix value (including a derivation) which is only available in one system, but which can be used safely in the context of another system. 

Instances of this are rare: in general you want to deal with [`inputs'`](#332-inputs).

### 3.3.2. `inputs'`

The [`inputs`](#331-inputs) de-systemized against the current system.

This means that you can use the following syntax:
```nix
inputs'.n2c.packages.nix2container
```
As opposed to:
```nix 
inputs.n2c.packages.x86_64-linux.nix2container
```

In general, you don't want to deal with `system` explicitly, but if you must, you can use [`inputs`](#331-inputs) instead (note the absence of prime `'` sign).

The `inputs/inputs'` notation was stolen from [flake-parts](https://flake.parts).

### 3.3.3. `meta`

IOGX will call `haskell.nix:cabalProject'` for each of your configured [`supportedCompilers`](#324-supportedcompilers), and with and without profiling enabled.

The `meta` field contains that information: `haskellCompiler` tells you the current compiler, `enableProfiling` tells you whether Haskell library and executable profiling is enabled, while `enableHaddock` is currently always set to `false` (but this attribute will eventually be removed). 

With the exception of `enableHaddock`, which is used in some repositories to defer plutus plugin errors, the other `meta` fields are unlikely to be needed, but are exposed anyway.

### 3.3.4. `pkgs`

A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your supported [`systems`], and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

A `nixpkgs` is also available at `inputs.nixpkgs.legacyPackages` or `inputs'.nixpkgs.legacyPackages.${pkgs.stdenv.system}` but those should *not* be used because they don't have the required overlays.

You may reference `pkgs` freely to get to the legacy packages or functions in `pkgs.lib`.

### 3.3.5. `config` 

The `haskell.nix` project configuration attrset as provided by the [`cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html#cabalproject) function.

### 3.3.6. `lib` 

Convenient `pkgs.lib` as provided by the [`cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html#cabalproject) function.

### 3.3.7. `cabalProjectLocal`

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty string.

See [`callCabalProjectToNix`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=cabalProjectLocal#callcabalprojecttonix) for details.

### 3.3.8. `sha256map` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty attrset.

See [`sha256map`](https://input-output-hk.github.io/haskell.nix/tutorials/source-repository-hashes.html?highlight=sha256Map#avoiding-modifying-cabalproject-and-stackyaml) for details.

### 3.3.9. `shellWithHoogle` 

Whether to include a Hoogle database in the development shell.

This field will be passed directly to `haskell.nix:cabalProject'` as `shell.withHoogle`.

It is recommended to leave this field to `false`, otherwise the entire Haskell dependency tree will need to be built with Haddock enabled.

This field is optional and defaults to `false`.

See [`shellFor`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=withHoogle#shellfor) for details.

### 3.3.10. `modules` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty list.

See [`modules`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=modules#modules) for details.

### 3.3.11. `overlays` 

This field will be passed as argument to `appendOverlays` 

This field is optional and defaults to the empty list.

See [`appendOverlays`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=appendOverlays#cabalproject) for details.

## 3.4. `nix/shell.nix`

```nix
{ inputs
, inputs'
, pkgs
, { meta
  , hsPkgs
  , ... 
  }@project ? null
, ...
}:
{ 
  name = "nix-shell";
  prompt = "$ ";
  welcomeMessage = "nix-shell";

  packages = [ ];
  scripts = { };
  env = { };
  enterShell = "";
}
```

If this file does not exist, then the shells will not be customized, but will still be available via `nix develop`.

This file will generate a `devShells.default` in your final flake outputs.

If `./nix/haskell.nix` is present, a shell will be generated for each compiler, with and without profiling enabled.

Once inside the default `nix develop` shell, you should run `list-flake-outputs` to see what's available.

### 3.4.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.4.2. `inputs'`

See [`inputs'`](#332-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.4.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.4.4. `project`

This argument is only present if `./nix/haskell.nix` exists.

This is the very value returned by `haskell.nix:cabalProject'`, which has been augmented with the relevant [`meta`](#334-meta) field as seen in [`cabal-project.nix`](#33-nixcabal-projectnix).

Each `haskell.nix` project produced by [haskell-project.nix](#33-nixcabal-projectnix) will generated a shell that can be configured in this file.

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
prompt = "\n\\[\\033[1;32m\\][nix-shell:\\w]\\$\\[\\033[0m\\] "
```
You can use the `project.meta` field here (if present) to customize your prompt like so:
```nix
prompt = 
  let 
    ghc = meta.haskellCompiler;
    profiled = if meta.enableProfiling then "-prof" else "";
    prefix = "foobar-${ghc}${profiled}";
  in 
    "\n\\[\\033[1;32m\\][${prefix}:\\w]\\$\\[\\033[0m\\] "
```
This field is optional and defaults to the familiar green `nix-shell` prompt.

### 3.4.7. `welcomeMessage`

When entering the shell, this welcome message will be printed.

The same caveat about escaping back slashes in [`prompt`](#346-prompt) applies here.

This field is optional and defaults to a simple welcome message using the [`name`](#345-name) field.

### 3.4.8. `packages`

You can add anything you want here, so long as it's a derivation with executables in the `/bin` folder. 

What you put here ends up in your `$PATH` (basically the `buildInputs` in `mkDerivation`).

For example:
```nix
packages = [
  pkgs.hello 
  pkgs.curl 
  pkgs.sqlite3 
  pkgs.nodePackages.yo
]
```

Here you could use `hsPkgs` to obtain some useful binaries:
```nix
packages = [
  project.hsPkgs.cardano-cli.components.exes.cardano-cli
  project.hsPkgs.cardano-node.components.exes.cardano-node
];
```

Be careful not to reference your project's own cabal packages via `hsPkgs`. 

If you do, then `nix develop` will build your project every time you enter the shell, and it will fail to do so if there are Haskell compiler errors.

This field is optional and defaults to the empty list. 

### 3.4.9. `scripts`

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
    enable = true;
  };

  waz.exec = ''
    echo "I don't have a group!"
  '';
};
```

`scripts` is an attrset where each attribute name is the script name each the attribute value is an attrset.

The attribute names (`foobar` and `waz` in the example above) will be available in your shell as commands under the same name.

The `description` field is an optional string that will appear next to the script name. 

The `exec` field is a required, non-empty string: it is the bash code to be executed when the script is run.

The `group` field is an optional string that will be used group scripts together so that they look prettier and more organized when printed. 

The `enable` field is an optional boolean that defaults to `true`, and can be used to include scripts conditionally, for example:
```nix 
foobar = { 
  exec = ''
    echo "I only run on Linux!"
  '';
  enable = pkgs.stdenv.hostPlatform.isLinux;
};
```

Each shell comes with several useful scripts gathered under the `iogx` group.

This field is optional and defaults to the empty attrset. 

### 3.4.10. `env`

Custom environment variables. 

```nix
env = {
  PGUSER = "postgres";
  THE_ANSWER = 42;
};
``` 

Considering the example above, the following bash code will be executed every time you enter the shell:

```bash 
export PGUSER="postgres"
export THE_ANSWER="42"
```

This field is optional and defaults to the empty attrset. 

### 3.4.11. `enterShell`
Standard nix `shellHook`, to be executed every time you enter the shell.

```nix
enterShell = ''
  # Bash code to be executed when you enter the shell.
  echo "I'm inside the shell!"
'';
```

This field is optional and defaults to the empty string. 

## 3.5. `nix/per-system-outputs.nix`

```nix
{ inputs, inputs', pkgs, projects ? null, ... }:
{
  packages.foo = { };
  checks.extra = { };
  apps.bar = { };
  operables = { };
  oci-images = { };
  nomadTasks = { };
  foobar = { };
}
```

Any custom flake outputs, per system.

This is where you define extra `packages`, `checks`, `apps` as well as any non-standard flake output like `nomadTasks`, `operables`, or `foobar`.

Remember that you can access these using `self` from `inputs` or `inputs'`, for example:
```nix 
inputs'.self.nomadTasks.marlowe-chain-indexer
inputs.self.nomadTasks.x86_64-linux.marlowe-chain-indexer
```

These outputs will be merged with the ones generated by IOGX, and an error will be thrown in case of a name clash.

You must *not* define `hydraJobs`, `ciJobs` nor `devShells` here.

If this file does not exist then no extra outputs will be added to the flake. 

By default CI will only build `packages`, `checks` and `devShells` (see [`includedPaths`](#394-includedpaths) about this).

### 3.5.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.5.2. `inputs'`

See [`inputs`](#332-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.5.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.5.4. `projects`

This argument is only present if `./nix/haskell.nix` exists.

The `projects` parameter is an attrset containing all the projects in the build matrix. 

Refer to the [`project`](#344-project) field in [`shell.nix`](#34-nixshellnix) for more information.

Each project has an attribute name which describes the current build configuration.

For example, in a configuration with two [`supportedCompilers`](#324-supportedcompilers), you would have:

```nix
projects.ghc8107 = { meta, hsPkgs, ... };
projects.ghc8107-profiled = { meta, hsPkgs, ... };
projects.ghc927 = { meta, hsPkgs, ... };
projects.ghc927-profiled = { meta, hsPkgs, ... };
```

## 3.6. `nix/top-level-outputs.nix`

```nix 
{ inputs, ... }:
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

Top-level flake outputs, not dependent on `system`. 

This is where you can define library functions or Nix values that are pure or `system`-independent.

An error is thrown in case of a name clash with existing top-level output groups (e.g. `packages`, `devShells`, `apps`).

Because these are system-independent outputs, you do not have access to the de-systemized `inputs'` nor to `pkgs`.

Only in this file is it appropriate, if needed, to reach for `nixpkgs` like so:
```nix
pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
lib = inputs.nixpkgs.lib;
```

The values defined in this file will be available via `self` anywhere else in your Nix code using `inputs` and `inputs'` equivalently.

For example:
```nix
{ inputs, inputs', ... }:

let 
  x = inputs.self.lib.f inputs'.self.networks.prod; 
in 
  { };
``` 

If this file does not exist then no extra top-level outputs will be added to the flake.

### 3.6.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

## 3.7. `nix/read-the-docs.nix`

```nix
{ inputs, inputs', pkgs, ... }:
{
  siteFolder = "doc/read-the-docs";
}
``` 

Configuration for your [`read-the-docs`](https://readthedocs.org) site. 

If no site is required, this file can be omitted.

Your shells will be augmented with several scripts to make developing your site easier, grouped under the tag `read-the-docs`.

In addition, a `read-the-docs-site` derivation will be built in CI and `packages.read-the-docs-site` will be added to the final flake outputs.

### 3.7.1. `siteFolder`

A Nix string representing a path, relative to the repository root, to your site folder containing the `conf.py` file.

If no site is required you can set this field to `null`, or omit the `read-the-docs.nix` file entirely. 

This field is optional and it defaults to `null`.

## 3.8. `nix/formatters.nix`

```nix
{ inputs, inputs', pkgs, ... }:
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

The `pre-commit` executable is also available in the shell.

All the tools are disabled by default.

If this file is missing, then no hooks will be run.

If this file is present, then `packages.pre-commit-check` will be added to the final flake outputs.

If `./nix/haskell.nix` exists, then one package will be added for each compiler instead.

Always run `list-flake-outputs` while inside any `nix develop` shell to see what's available.

### 3.8.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.8.2. `inputs'`

See [`inputs'`](#332-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.8.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.8.4. `enable` 

It is sufficient to set the `enable` flag to `true` to make the tool active.

When enabled, some tools expect to find a configuration file in the root of the repository:

| Tool Name | Config File | 
| --------- | ----------- |
| `stylish-haskell` | `.stylish-haskell.yaml` |
| `editorconfig-checker` | `.editorconfig` |
| `fourmolu` | `fourmolu.yaml` (note the missing dot `.`) |
| `hlint` | `.hlint.yaml` |
| `hindent` | `.hindent.yaml` |

Currently there is no way to change the location of the configuration files.

Each tool knows which file extensions to look for, which files to ignore, and how to modify the files in-place.

### 3.8.5. `extraOptions` 

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

## 3.9. `nix/ci.nix`

```nix
{ inputs, inputs', pkgs, ... }:
{ 
  includedPaths = [];

  excludedPaths = [];
}
```

Configuration for the jobset to run in CI.

This determines what your final `hydraJobs` flake outputs looks like. 

If `haskell.nix` exists, then all Haskell components (excluding profiled builds) are added to `hydraJobs`.

All custom derivations nested under `packages` and `checks` that you may have added in you [`per-system-outputs.nix`](#35-nixper-system-outputsnix) will also be added to `hydraJobs`.

If `./nix/read-the-docs` exists, then `packages.read-the-docs-site` will be added. 

One or more `packages.pre-commit-check-*` is also added to `hydraJobs`.

If this file does not exit then only the default jobset will be run in CI, which includes all `packages`, `checks` and `devShells` as found in the final `inputs'.self`.

### 3.9.1. `inputs`

See [`inputs`](#331-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.9.2. `inputs'`

See [`inputs`](#332-inputs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.9.3. `pkgs`

See [`pkgs`](#333-pkgs) from [`cabal-project.nix`](#33-nixcabal-projectnix).

### 3.9.4. `includedPaths`

This is a list of *strings*, representing attribute *paths* in the final flake outputs (i.e. paths in `inputs'.self`).

This field is where you would add the derivations defined in your [`per-system-outputs.nix`](#35-nixper-system-outputsnix).

For example:
```nix
# nix/per-system-outputs.nix 
{ ... }:
{
  foo.ok = {
    nested = {
      drv1 = {};
      drv2 = {};
    };
    broken = {};
  };
  foo.broken = {
    drv1 = {};
    drv2 = {};
  };
  packages.waz = {
    broken = {};
    ok = {};
  };
  apps.nested = {
    drv1 = {};
    drv2 = {};
  };
}

# nix/ci.nix 
{ ... }:
{
  includedPaths = [
    "foo.ok.nested"
    "packages.waz.ok"
    "apps.nested"
  ];
}
```
Behind the scenes, this will populate `hydraJobs` like so:
```nix
hydraJobs = {
  foo.ok.nested = inputs.self.foo.ok.nested;
  packages.waz.ok = inputs.self.packages.waz.ok;
  apps.nested = inputs.self.apps.nested;
}
```

### 3.9.5. `excludedPaths`

After populating `hydraJobs` with [`includedPaths`](#includedpaths), the paths listed in `excludedPaths` will be *removed* from the final `hydraJobs`. 

This is a good place to exclude derivations based on the current system.

For example if you have this [`per-system-outputs.nix`](#35-nixper-system-outputsnix):
```nix
{ 
  packages.broken = {
    pkg1 = null;
    pkg2 = null;
  };

  packages.ok = {
    pkg3 = null;
    pkg4 = null;
    broken-on-linux = null;
    broken-on-darwin = null;
  };
};
```
You could have this setup:
```nix
{
  includedPaths = [
    # By default all packages are already included so this list can be empty.
  ];

  excludedPaths = [
    "packages.broken"
  ] 
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux 
  [
    "packages.ok.broken-on-darwin"
  ] 
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin 
  [
    "packages.ok.broken-on-linux"
  ];
}
```

# 4. Future Work

In the future we plan to develop the following features:

- Hoogle Support
- Automatic Test Coverage Reports
- Automatic Benchmarking in CI
- Broken Link Detection 
- Option to exclude specific jobs from the `required` aggregated job.