**WORK IN PROGRESS**

# IOGX 

`IOGX` is a flake template that facilitates the development of Haskell projects at IOG.

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

# Documentation

This `README` is the main source of documentation for `IOGX`. 

It acts a tutorial and a reference to the API.

To get started run: 
```bash
nix flake init --template github:input-output-hk/iogx
```

This will generates a [`flake.nix`](./template/flake.nix) as well as a [`nix`](./template/nix) folder containing a number of file stubs.

You will fill the stubs while leaving your [`flake.nix`](./template/flake.nix) largely untouched.

**`IOGX` will populate your [`flake.nix`](./template/flake.nix) outputs based on the contents of the [`nix`](./template/nix) folder.**

We say that these files form the file-system-based API of IOGX.

Click on the file name to jump to its reference section: 

0. [`flake`](./template/flake.nix) - Standard flake, mostly boilerplate 
1. [`iogx-config`](./iogx-config.nix) — Entrypoint configration for IOGX 
2. [`haskell-project`](./haskell-project.nix) — Definition of the [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project
3. [`shell`](./shell.nix) — Nix development environment 
4. [`hydra-jobs`](./hydra-jobs.nix) — Jobset to be run on IOHK's Hydra CI
5. [`per-system-outputs`](./per-system-outputs.nix) — Custom system-dependent flake outputs
6. [`top-level-outputs`](./top-level-outputs.nix) — Custom system-independent flake outputs
7. [`read-the-docs`](./read-the-docs.nix) — Support for a [`read-the-docs`](https://readthedocs.org) site
8. [`pre-commit-check`](./pre-commit-check`.nix) — Configurable [`pre-commit`](https://github.com/cachix/pre-commit-hooks.nix) hooks

# flake.nix 
```nix
{
  description = "Foo"; # (1)

  inputs = {
    iogx.url = "github:zeme-iohk/iogx"; # (2)
  };

  outputs = inputs: inputs.iogx.lib.mkFlake inputs ./.; # (3)
 
  nixConfig = { # (4)

    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];

    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];

    allow-import-from-derivation = true; 
  };
}
```

[`flake.nix`](./template/flake.nix) is the entrypoint for the nix code. This file is mostly boilerplate and will remain largely untouched.


**(1) `description`**

Arbitrary description for the flake. This string is displayed when running `nix flake info` and other flake commands. It should be like a short title for your project. 

**(2) `inputs`**

Your flake must define `iogx` among its inputs. In turn, `IOGX` manages the following inputs for you: CHaP, flake-utils, haskell.nix, nixpkgs, hackage, iohk-nix, sphinxcontrib-haddock, pre-commit-hooks-nix, haskell-language-server, nosys. You must *not* add those inputs again, or you will get an error message. `IOGX` will provide the latest versions of those inputs. Keeping IOGX up-to-date implies having the latest `CHaP`, `haskell.nix`, etc. However it is inevitable that you will want to use a different versions of the implicit inputs, for example because IOGX has not been updated yet. It is possible to ovveride the implicit inputs in one of two ways. For example, if you need a newer version of hackage, you may do the following:
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
It is of course possible to add other inputs (different than the ones implicitely ma naged by IOGX) in the normal way. For example to add nix2container
```nix
inputs = {
  iogx.url = "github:zeme-iohk/iogx"; 
  n2c.url = "github:nlewo/nix2container";
};
```
Note that IOGX will merge (union) its' implicit inputs and the new imputs like (n2c) into a single attrset. This set will be simply called `inputs` but it will give access to all the inputs and will be exposed by the API. At heart it is just a shorthand:
```nix
inputs.haskell-nix -> inputs.iogx.inputs.haskell-nix.
inputs.n2c 
```
Again it is safe to union the the `inputs` sets because clashes have been detected and errored out at this point.

**(3) `mkFlake`**

This line is boilerplate and should not be changed. IOGX hosts its main `mkFlake` function in the `lib` top-level attribute. There are other functions in `lib`, but they are not needed to use IOGX and will be documented at a later date TODO. You must pass the current directory `./.` but soon this requirement will be lifted.

**(4) `nixConfig`**

The `nixConfg` attrset must not be changed, but it can be added to. You can add new substituters and trusted-public-keys, but do not delete the existing ones, or you won't have access to IOG caches. In order this to work correctly, it is sufficient to make sure that the following two lines are included in your `/etc/nix/nix.conf`:
```txt
trusted-users = $USER
experimental-features = nix-command flakes
```
Replace `$USER` with the result of running `whoami`. You may need to reload the nix daemon on darwin:
```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```
Similarly, leave `allow-import-from-derivation` set to `true` for `haskell.nix` for work correctly.

# iogx-config.nix

```nix
{ 
  repoRoot = ./.; # (1)
  systems = [ "x86_64-linux" "x86_64-darwin" ]; # (3)
  haskellCompilers = [ "ghc8107" ]; # (4)
  defaultHaskellCompiler = "ghc8107"; # (5)
  shouldCrossCompile = true; # (6)
} 
```

Configuration for your `IOGX` flake. This file *must* be called `nix/iogx-config.nix` and be located inside the top-level `nix` folder, otherwise the `mkFlake` function in `flake.nix` fill fail. This configuration is typechecked against a schema, therefore invalid values will throw immediately useful error messages. Additional fields are not permitted in the attrset. All fields are optional and default to sensible values.

**(1) `repoRoot`**

This must be a Nix path to an existing folder containing your `cabal.project` file. 
This field is optional and defaults to `inputs.self` (the root of your repository whish is were the `cabal.project` file is usually located).

**(3) `systems`**

The systems against which your project can be built. These are the standard Nix values found in `pkgs.stdenv.system`.
This field is optionl and defaults to `[ "x86_64-linux" "x86_64-darwin" ]`. It cannot be the empty list or contain unknown values.

**(4) `haskellCompilers`**

The list of avaialble haskellCompilers. Currently two GHC versions are supported and provided by IOGX:  "ghc8107" and "ghc927".
A list with two or more element will grow your flake putputs larger. Define a set of desired GHC versions and get a `devShell` for each that comes with a complete haskell toolchain. `mkFlake` will consider all `haskellCompilers`, so that your final `packages` will include all your project's components, nested by compiler name. Similarly your `apps` will contain the executables, testsuites and benchmarks. Your `hydraJobs` will build your project against each compiler. A version built with profiling enabled is avaialble for each component out of the box. 
This field is optional and defaults to the singleton list ["ghc8107"]

**(5) `defaultHaskellCompiler`**

One one compiler toolchain can be visibile in the $PATH at a time. When calling `nix develop`, the `defaultHaskellCompiler` will be selected. Later you will learn how to enter a shell providing another one of the `haskellCompilers` which is not the `defaultHaskellCompiler`.
This field is optional and defaults to the first compiler (leftmost) in `haskellCompilers`.

**(6) `shouldCrossCompile`**

Cross-compilation on windows is done via mingwW64 on x86_64-linux only. When set to true, your flake outputs will include derivations to cross-build for windows. If you project cannot be cross-compiled then set this field to false. This field is optional and defaults to true.

# haskell-project.nix

This file must be located in `nix/haskell-project.nix`. It is the only other file that is required by IOGX. Writing this file requires a non-trivial undertanding of nix and haskell.nix and therefore it should be maintained by a nix expert or by SC-DEVEMP-TEAM. This file receives a few parameters by IOGX and returns a set of values that will be used to call `haskell.nix:cabalProject'` behind the scenes. It is a function that receives the current `meta` configuration of the project and must return an attrset with the fields described below, of which only `packages` is required. This file is imported once for each system, then 4 times for each compiler.

```nix
{ inputs # (1)
, inputs' # (2)
, pkgs # (3)
, { haskellCompiler # (4)
  , enableHaddock # (5)
  , enableProfiling # (6)
  , enableCross # (7)
  }@meta # (8)
}:
{
  cabalProjectLocal = ""; # (5)
  sha256map = {}; # (6)
  shellWithHoogle = false; # (7)
  packages = {}; # (8)
}
```

`inputs`
All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the inputs defined in your flake. You will also find the `self` attribute here.
NOTE: These inputs have been desystemized against the current system.
This means that you can use the following syntax:
```nix
inputs.n2c.packages.nix2container
```
As opposed to:
```nix 
inputs.n2c.packages.x86_64-darwin.nix2container
```
In general you don't want to deal with `system` explicitely. But if you must, you can use `inputs'` (inputs prime - see below)

# inputs'

Original merged inputs. All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the inputs defined in your flake. You will also find the `self` attribute here. NOTE: These inputs have *not* been desystemized, they are the original inputs from iogx and your flake.nix. 
This means that you must always specify the system, as in the following example:    
```nix
inputs.n2c.packages.x86_64-darwin.nix2container
```
You may want to use this in case you need a nix value (incuding a derivation) which is only avaialble on one system, but which can be used safely in the context of another system. Instances of this are rare. In general you want to deal with `inputs`.
The `inputs` - `inputs'` notation has been taken from `flake-parts`.

# `pkgs`

A `nixpkgs` instantiated against the current system (available in `pkgs.stdenv.system` and one of `iogx-config.nix:systems`) and overlaiedwith goodies from `haskell.nix` and `iohk-nix`. A nixpkgs is also avaialble at `inputs.nixpkgs.legacyPagckages` or `inputs'.nixpkgs.legacyPcakges.$system` but that should never be used as it doens't have the required ovelays.

# `haskellCompiler`

IOGX needs to call haskell.nix.cabalProject'` for each compiler defined in your iogx-config:haskellCompilers. In addition, it can build that project with profiling `enableProfiling` and/or with `cross compilation (if `shouldCrossCompile` had been set to true) `enableHaddock` is currently always set to `false`. With this in mind, we have a build matrix of 4 dimensions: `system` (implicit in `pkgs.stdenv.system`), haskellCompiler (one of `hasskellCompoilers`) `enableCross` {} and enableHaddock. This means that with the default configuration this file will be imported 2 (systems) x 1 (haskellCompilers) x 2 {enableCross true | false} x 2 { enableHaddock true | false } = 8 times.
The `meta` paremeter nor its inner fields are actually likely to be used in `haskell-project.nix`, but they are exposed nontheless. The exception is enableHaddock which is used explicitely.

# cabalProjectLocal 

This field will be passed directly to haskell.nixcabalProject'. This field is optional and defaults to the empty string "".
See 

# shel256map 

This field is optona; and defaults to the empty attrset.

# shellWithHoogle

Whether to add hoogle to the shell. This field is optiona and defaults to false. It is reccomended to leave this field to false, otjherwise the entire haskell dependency tree will be retriggered as it needs to build every single package with haddock.

# packages 

This is the classic `pacakges` attrset in a `haskell.nix` module. It is sufficient to pass one.
See 


# shell.nix
```nix
{ inputs, inputs', pkgs, project@{ meta, hsPkgs, shell, ... } }:
{ 
  derivationName = "TODO";
  prompt = "$ ";
  welcomeMessage = "TODO";

  packages = [ ];
  scripts = { };
  env = { };
  enterShell = "";
}
```
Similarly to `haskell-project.nix` we have a shell for each element in the build matrix. The function parameters are similar to those in `haskell-project.nix`. But instead of a `meta` argument, we have a `project` parameter.
Project is the very attrset returned by `haskell.nix:cabalProject'`. In fact, each shell is built on top of a haskell.nix project, and here we obtain a reference to it. Note that this attrset has been automent with an additional field named meta, which has the equavement value to the `meta` argument in the corresponding call to `haskell-project.nix`.
The `meta` attrset may be more useful here as it could be used to personalize the first three fields.
For example you could include meta.haskellCompiler or a flag for meta.enableProfiling in your shellprompt. Note that the `nix/shell.nix` may not exist, in which case all its fields are assumed to be defaulted. Or it can return the empty attrset {}. In both cases, this simoly means do not augment the default shell, it does not mean that a shell will not be avaialble.


Be careful not to reference the project's own haskell packages in `hsPkgs`. If you do, 
then `nix develop` will build your project every time and it will fail to 
drop you into the shell if there are compiler errors.

`derivationName`
This field is optiona and is litterally the name field in the implict call to `pkgs.mkShell` that will create this shell.
It's mostly useless but exposed nontheless. This is an optional field that defaults simply to "dev-shell".
But it is used to fill the `prompt` and `welcomeMessage` fields in case they are also left out.

`prompt`

Shell prompt i.e. the value of the `PS1` evnvar. This is what you see in your terminal to the left of what you type.
You can use ansii coloring this this. However bote that because this is a nix string that will be embedded in a bash
string, you need to double-escape the left slashes:
So if you would normally do this in bash:
```bash
export PS1="\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] "
```
Then you need to do this in `shell.nix`
```nix
prompt = "\n\\[\\033[1;32m\\][nix-shell:\\w]\\$\\[\\033[0m\\] ";
```
You can use the meta fields here to customize your prompt like so:
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
This field is optional and defaults to the familiar green nix-shell promopt using the `derivationName`.

`welcomeMessage`

When entering the shell, a welcome message will be printed on top of a long informational message.
The same caveat about esaping back slashes applies here.
This field is optional and defaults to a simple welcome messaage using the `derivationName and emojis
```nix 
welcomeMessage = "🤟 \\033[1;31mWelcome to FOOBAR\\033[0m 🤟";
```      

`packages`
You can add anything you want here, so long as it's a derivation with executables in the `/bin` folder. What you put here ends up in your $PATH while inside the shell. This is turn into `buildInputs` in `mkDerivation`.
For example,
```nix
packages = [
  pkgs.hello 
  pkgs.curl 
  pkgs.sqlite3 
  pkgs.nodePackages.yo
];
```
This field is optional and defaults to the empty list `[]`. Sono packages are already included by default by IOGX. If you clash them, you'll get a wardning.
The project field itself, and especially its hsPkgs can be used to populate the rest of the shell, for example to add some executables in your packages:
```
  packages = [
    project.hsPkgs.cardano-cli.components.exes.cardano-cli
    project.hsPkgs.cardano-node.components.exes.cardano-node
  ];
```

`scripts` 
Custom scripts for your shell. For example
```
scripts = {
  foobar = {
    exec = ''
      # Bash code to be executed whenever the script `foobar` is run.
      echo "Delete me from your shell-module.nix!"
    '';
    description = ''
      You might want to delete the foobar script.
    '';
    group = "group-name";
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

`per-system-outputs`

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

# top-level-outputs

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

# read-the-docs 

TODO 

# pre-commit-check

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

# hydra-jobs 

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