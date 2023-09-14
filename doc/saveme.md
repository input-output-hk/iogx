
# The `inputs.iogx.lib.mkFlake` function





This file is optional and contains fundamental configuration values for your Haskell project.

### 3.2.1. `supportedCompilers`

The non-empty list of GHC versions that can build your project. 

Currently these GHC versions are supported and provided by IOGX: `ghc8107`, `ghc927`, `ghc928` and `ghc962`.

This field is required.

### 3.2.2. `defaultCompiler`

Only one compiler at a time can be visible in the `$PATH` in the shell.

When calling `nix develop`, the `defaultCompiler` will be selected. 

You you want to enter a shell with a different compiler, run `list-flake-outputs` while inside any other `nix develop` shell, and you will be presented with a list of options.

This field is optional and defaults to the first (leftmost) compiler in `supportedCompilers`.

### 3.2.3. `enableCrossCompilation`

Cross-compilation on Windows is available via `mingwW64` on `x86_64-linux` only. 

If enabled, cross-compiled packages for you haskell project will be built in CI.

This field is optional and defaults to `false`.

### 3.2.4. `cabalProjectFolder`

This is a string representing the path, relative to the `repoRoot`, where the `cabal.project` file is located.

This field is optional and default to `"."`.

### 3.2.4. `defaultChangelogPackages`

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

### `enableCombinedHaddock` 

When enabled, your `./nix/read-the-docs.nix` site will have access to Haddock symbols for your Haskell packages.

Combining haddock artifacts takes a significant amount of time and may slow do CI.

You should enable this only on Linux like this:

```nix
# ./nix/haskell.nix
{ system, ... }: 
{
  enableCombinedHaddock = system == "x86_64-linux";
}
```

When this field is `false` both `projectPackagesWithHaddock` and `combinedHaddockPrologue` fields below will be ignored.

This field is optional and default to `false`.

### `projectPackagesWithHaddock` 

The list of cabal package names to include in the combined Haddock.

This field is optional and default to the empty list `[]`.

### `combinedHaddockPrologue` 

A string acting as prologue for the combined Haddock.

This field is optional and default to the empty string `""`.

## 3.3. `nix/cabal-project.nix`

```nix
{ nix
, inputs 
, inputs' 
, pkgs 
, system
, l
, { haskellCompiler, enableHaddock, enableProfiling, ... }@meta 
, config 
, ...
}:
{
  cabalProjectLocal = ""; 
  sha256map = { }; 
  shellWithHoogle = false; 
  shellBuildInputs = [];
  modules = [ ]; 
  overlays = [ ];
}
```

This file is only used if `./nix/haskell.nix` exists, and returns the arguments that will be used to create a `haskell.nix` project. 

See `haskell.nix`'s [`cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html#cabalproject) function for details.

This file will be evaluated once for each element in your GHC build matrix: if your [`supportedCompilers`](#321-supportedcompilers) has 2 elements, then `./nix/cabal-project.nix` will be called 4 times (taking into account profiled and non-profiled builds).

This will largely affect what your final flake outputs look like. You should run `list-flake-outputs` while inside a `nix develop` shell to see what's available.

If this file does not exist then a `haskell.nix` project will still be created using default values and common heuristics.

### 3.3.1. `meta`

IOGX will call `haskell.nix:cabalProject'` for each of your configured [`supportedCompilers`](#321-supportedcompilers), and with and without profiling enabled.

The `meta` field contains that information: `haskellCompiler` tells you the current compiler, `enableProfiling` tells you whether Haskell library and executable profiling is enabled, while `enableHaddock` is currently always set to `false` (but this attribute will eventually be removed). 

With the exception of `enableHaddock`, which is used in some repositories to defer plutus plugin errors, the other `meta` fields are unlikely to be needed, but are exposed anyway.

### 3.3.2. `config` 

The `haskell.nix` project configuration attrset as provided by the [`cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html#cabalproject) function.

### 3.3.3. `cabalProjectLocal`

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty string.

See [`callCabalProjectToNix`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=cabalProjectLocal#callcabalprojecttonix) for details.

### 3.3.4. `sha256map` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty attrset.

See [`sha256map`](https://input-output-hk.github.io/haskell.nix/tutorials/source-repository-hashes.html?highlight=sha256Map#avoiding-modifying-cabalproject-and-stackyaml) for details.

### 3.3.5. `shellWithHoogle` 

Whether to include a Hoogle database in the development shell.

This field will be passed directly to `haskell.nix:cabalProject'` as `shell.withHoogle`.

It is recommended to leave this field to `false`, otherwise the entire Haskell dependency tree will need to be built with Haddock enabled.

This field is optional and defaults to `false`.

See [`shellFor`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=withHoogle#shellfor) for details.

### 3.3.6. `shellBuildInputs` 

Additional build inputs to add to the shell provided by `haskell.nix`.

This field will be passed directly to `haskell.nix:cabalProject'` as `shell.buildInputs`.

This field is optional and defaults to the empty list `[]`.

See [`shellFor`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=withHoogle#shellfor) for details.

### 3.3.7. `modules` 

This field will be passed directly to `haskell.nix:cabalProject'`. 

This field is optional and defaults to the empty list.

See [`modules`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=modules#modules) for details.

### 3.3.8. `overlays` 

This field will be passed as argument to `appendOverlays` 

This field is optional and defaults to the empty list.

See [`appendOverlays`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=appendOverlays#cabalproject) for details.

## 3.4. `nix/shell.nix`

```nix
{ nix 
, inputs
, inputs'
, pkgs
, system
, l
, { meta, hsPkgs, ... }@project ? null
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

### 3.4.1. `project`

This argument is only present if `./nix/haskell.nix` exists.

This is the very value returned by `haskell.nix:cabalProject'`, which has been augmented with the relevant [`meta`](#331-meta) field as seen in `./nix/cabal-project.nix`.

Each `haskell.nix` project produced by `./nix/cabal-project.nix` will generated a shell that can be configured in this file.

Below your will find an example of how to use `hsPkgs` and `meta`.

### 3.4.2. `name`

This field will be used as the shell's derivation name and it will also be used to fill in the default values for `prompt` and `welcomeMessage` below.

This field is optional and defaults to `nix-shell`.

### 3.4.3. `prompt`

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

### 3.4.4. `welcomeMessage`

When entering the shell, this welcome message will be printed.

The same caveat about escaping back slashes in `prompt` applies here.

This field is optional and defaults to a simple welcome message using the `name` field.

### 3.4.5. `packages`

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

### 3.4.6. `scripts`

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

### 3.4.7. `env`

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

### 3.4.8. `enterShell`
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
{ nix, inputs, inputs', pkgs, systems, l, projects ? null, ... }:
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

### 3.5.1. `projects`

This argument is only present if `./nix/haskell.nix` exists.

The `projects` parameter is an attrset containing all the projects in the build matrix. 

Refer to the [`project`](#341-project) field in [`shell.nix`](#34-nixshellnix) for more information.

Each project has an attribute name which describes the current build configuration.

For example, in a configuration with two [`supportedCompilers`](#321-supportedcompilers), you would have:

```nix
projects.ghc8107 = { meta, hsPkgs, ... };
projects.ghc927 = { meta, hsPkgs, ... };
```

## 3.6. `nix/top-level-outputs.nix`

```nix 
{ nix, inputs, l, ... }:
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

Because these are system-independent outputs, you do not have access to the de-systemized `inputs'` nor to `pkgs` or `system`.

Also note that if you want to use the `nix` argument here to access other files, those files will also not have access to `inputs'` nor to `pkgs` or `system`.

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

  purs-tidy.enable = false;
  purs-tidy.extraOptions = "";
}
```

Configuration for code formatters and linters.

These are fed to [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix), which is run whenever you `git commit`.

The `pre-commit` executable is also available in the shell.

All the tools are disabled by default.

If this file is missing, then no hooks will be run.

If this file is present, then `packages.pre-commit-check` will be added to the final flake outputs.

Always run `list-flake-outputs` while inside any `nix develop` shell to see what's available.

### 3.8.1. `enable` 

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

### 3.8.2. `extraOptions` 

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
  
  includeDefaultOutputs = true;

  includedPaths = [];

  excludedPaths = [];
}
```

Configuration for the jobset to run in CI.

This determines what your final `hydraJobs` flake outputs looks like. 

### includeDefaultOutputs 

If this is set to `true`, then all `packages`, `checks` and `devShells` (coming from `inputs'.self`) will be added to `hydraJobs`.

If this is set to `false`, then no outputs will be added to `hydraJobs`, and you will have to populate it explicitly using `includedPaths` and `excludedPaths`.

### 3.9.1. `includedPaths`

This is a list of *strings*, representing attribute *paths* in the final flake outputs (i.e. paths in `inputs'.self`).

If you have defined non-standard outputs in your [`per-system-outputs.nix`](#35-nixper-system-outputsnix), this is the place to add them.

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

### 3.9.2. `excludedPaths`

After populating `hydraJobs` with `includedPaths`, the paths listed in `excludedPaths` will be *removed* from the final `hydraJobs`. 

This is a good place to exclude derivations based on the current system.

For example if you have this `./nix/per-system-outputs.nix`.

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

