# Options Reference 

1. [`flake.nix`](#flakenix) 
    The options for this flake.
1. [`inputs.iogx.lib.mkFlake`](#mkflake) 
    Makes your flake outputs.
2. [`pkgs.lib.iogx.mkHaskellProject`](#mkhaskellproject) 
    Makes a [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project decorated with the `iogx` overlay.
3. [`pkgs.lib.iogx.mkShell`](#mkshell)
    Makes a `devShell` with `pre-commit-check` and tools.

---

### `"flake.nix"`

**Type**: submodule







---

### `"flake.nix".description`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# flake.nix 
{ 
  description = "My Haskell Project";
  inputs = {};
  outputs = _: {};
  nixConfig = {};
}

```


Arbitrary description for the flake. 

This string is displayed when running `nix flake info` and other flake 
commands. 

It can be a short title for your project. 


---

### `"flake.nix".inputs`

**Type**: attribute set

**Default**: `{ }`


**Example**: 
```nix
# Template Haskell ./flake.nix
{ 
  description = "";
  inputs = {
    iogx = {
      url = "github:input-output-hk/iogx";
      inputs.hackage.follows = "hackage";
      inputs.CHaP.follows = "CHaP";
      inputs.haskell-nix.follows = "haskell-nix";
      inputs.nixpkgs.follows = "haskell-nix/nixpkgs-2305";
    };

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };
  };
  outputs = _: {};
  nixConfig = {};
}

# Template Vanilla ./flake.nix
{ 
  description = "";
  inputs = {
    iogx.url = "github:input-output-hk/iogx";
  };
  outputs = _: {};
  nixConfig = {};
}       

```


Your flake *must* define `iogx` among its inputs. 

In turn, IOGX manages the following inputs for you: 
[CHaP](https://github.com/input-output-hk/cardano-haskell-packages), 
[haskell.nix](https://github.com/input-output-hk/haskell.nix), 
[nixpkgs](https://github.com/NixOS/nixpkgs), 
[hackage.nix](https://github.com/input-output-hk/hackage.nix), 
[iohk-nix](https://github.com/input-output-hk/iohk-nix), 
[sphinxcontrib-haddock](https://github.com/michaelpj/sphinxcontrib-haddock), 
[pre-commit-hooks-nix](https://github.com/cachix/pre-commit-hooks.nix), 
[haskell-language-server](https://github.com/haskell/haskell-language-server), 
[easy-purescript-nix](https://github.com/justinwoo/easy-purescript-nix). 

If you find that you want to use a different version of some of the 
implicit inputs, for instance because IOGX has not been updated, or 
because you need to test against a specific branch, you can use the 
`follows` syntax like in the example above.

Note that the Haskell template `flake.nix` does this by default with 
`CHaP`, `hackage.nix` and `haskell.nix`.

It is of course possible to add other inputs (not already managed by 
IOGX) in the normal way. 

For example, to add `nix2container` and `cardano-world`:

```nix
inputs = {
  iogx.url = "github:inputs-output-hk/iogx";
  n2c.url = "github:nlewo/nix2container";
  cardano-world.url = "github:input-output-hk/cardano-world";
};
```

If you need to reference the inputs managed by IOGX in your flake, you 
may use this syntax:

```nix
nixpkgs = inputs.iogx.inputs.nixpkgs;
CHaP = inputs.iogx.inputs.CHaP;
haskellNix = inputs.iogx.inputs.haskell-nix;
```

If you are using the `follows` syntax for some inputs, you can avoid 
one level of indirection when referencing those inputs:
```nix
nixpkgs = inputs.nixpkgs;
CHaP = inputs.CHaP;
haskellNix = inputs.haskell-nix;
```

If you need to update IOGX (or any other input) you can do it the 
normal way:

```bash
nix flake lock --update-input iogx 
nix flake lock --update-input haskell-nix 
nix flake lock --update-input hackage 
nix flake lock --update-input CHaP 
```


---

### `"flake.nix".nixConfig`

**Type**: null or package

**Default**: `{ }`


**Example**: 
```nix
# Template ./flake.nix 
{ 
  description = "";
  inputs = {};
  outputs = _: {};

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


---

### `"flake.nix".outputs`

**Type**: function that evaluates to a(n) (attribute set)

**Default**: `<function>`


**Example**: 
```nix
# Template ./flake.nix
{
  description = "";
  inputs = {};
  nixConfig = {};

  outputs = inputs: inputs.iogx.lib.mkFlake {

    inherit inputs;

    repoRoot = ./.;

    outputs = import ./nix/outputs.nix;

    # systems = [ "x86_64-linux" "x86_64-darwin" ];

    # debug = false;

    # nixpkgsArgs = {
    #   config = {};
    #   overlays = [];
    # };

    # flake = {};
  };
}

```


Your flake `outputs` are produced using [`mkFlake`](#mkflake).


---

### `mkFlake`

**Type**: core API function



**Example**: 
```nix
# flake.nix
{
  outputs = inputs: inputs.iogx.lib.mkFlake {
    inherit inputs;
    repoRoot = ./.;
    debug = false;
    nixpkgsArgs = {};
    systems = [ "x86_64-linux" "x86_64-darwin" ];
    outputs = { repoRoot, inputs, pkgs, lib, system }: [];
  };
}

```


The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

In this document, options for the input attrset are prefixed by `mkFlake.<in>`.


---

### `mkFlake.<in>.debug`

**Type**: boolean

**Default**: `false`




If enabled, IOGX will trace debugging info to standard output.


---

### `mkFlake.<in>.flake`

**Type**: attribute set

**Default**: `{ }`


**Example**: 
```nix
{
  lib.bar = _: null;

  packages.x86_64-linux.foo = null;
  devShells.x86_64-darwin.bar = null;

  networks = {
    prod = { };
    dev = { };
  };
}

```


A flake-like attrset.

You can place additional flake outputs here, which will be recursively updated with the attrset from [`mkFlake.<in>.outputs`](#mkflakeinoutputs).

This is a good place to put system-independent values like a `lib` attrset or pure Nix values.


---

### `mkFlake.<in>.inputs`

**Type**: attribute set





Your flake inputs.

You almost certainly want to do `inherit inputs;` here (see the example in [`mkFlake`](#mkflake))


---

### `mkFlake.<in>.nixpkgsArgs`

**Type**: attribute set

**Default**: 
```nix
{ 
  config = { }; 
  overlays = [ ]; 
}

```


**Example**: 
```nix
# flake.nix
{
  outputs = inputs: inputs.iogx.lib.mkFlake {
    inherit inputs;
    outputs = import ./nix/outputs.nix;
    nixpkgsArgs = {
      overlays = [(self: super: { 
        acme = super.callPackage ./nix/acme.nix { }; 
      })];
    };  
  };
}

```


Internally, IOGX calls `import inputs.nixpkgs {}` for each of your [`mkFlake.<in>.systems`](#mkflakeinsystems).

Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.


---

### `mkFlake.<in>.outputs`

**Type**: function that evaluates to a(n) list of (attribute set)



**Example**: 
```nix
# flake.nix 
{
  outputs = inputs: inputs.iogx.lib.mkFlake {
    outputs = import ./outputs.nix;
  };
}

# outputs.nix
{ repoRoot, inputs, pkgs, lib, system }:
[
  {
    cabalProject = lib.iogx.mkHaskellProject {};
  }
  {
    packages.foo = repoRoot.nix.foo;
    devShells.foo = lib.iogx.mkShell {};
  }
  {
    hydraJobs.ghc928 = inputs.self.cabalProject.projectVariants.ghc928.iogx.hydraJobs;
  }
]

```


A function that is called once for each system in [`mkFlake.<in>.systems`](#mkflakeinsystems).

This is the most important option as it will determine your flake outputs.

`outputs` receives an attrset and must return a list of attrsets.

The returned attrsets are recursively merged top-to-bottom. 

Each of the input attributes is documented below.

#### `repoRoot`

Ordinarily you would use the `import` keyword to import nix files, but you can use the `repoRoot` variable instead.

`repoRoot` is an attrset that can be used to reference the contents of your repository folder instead of using the `import` keyword.

Its value is set to the path of [`mkFlake.<in>.repoRoot`](#mkflakeinreporoot).

For example, if this is your top-level repository folder:
```
* src 
  - Main.hs 
- cabal.project 
* nix
  - outputs.nix
  - alpha.nix
  * bravo
    - charlie.nix 
    - india.nix
    - hotel.json
    * delta 
      - echo.nix
      - golf.txt
```

Then this is how you can use the `repoRoot` attrset:
```nix
# ./nix/alpha.nix
{ repoRoot, ... }:
repoRoot."cabal.project"

# ./nix/bravo/charlie.nix
{ repoRoot, ... }:
repoRoot.nix.bravo."hotel.json"

# ./nix/bravo/india.nix
{ pkgs, ... }:
pkgs.hello

# ./nix/bravo/delta/echo.nix
{ repoRoot, lib, ... }:
arg1:
{ arg2 ? null }:
lib.someFunction arg1 arg2 repoRoot.nix.bravo.delta."golf.txt"

# ./nix/per-system-outputs.nix
{ repoRoot, inputs, pkgs, system, lib, ... }:
{ 
  packages.example = 
    let 
      a = repoRoot.nix.alpha;
      c = repoRoot.nix.bravo.charlie;
      e = repoRoot.nix.bravo.delta.echo "arg1" {};
      f = repoRoot.nix.bravo.delta."golf.txt";
      g = repoRoot.src."Main.hs";
    in
      42; 
}
```

Note that the Nix files do not need the `".nix"` suffix, while files with any other extension (e.g. `golf.txt`) must include the full name to be referenced.

In the case of non-Nix files, internally IOGX calls `builtins.readFile` to read the contents of that file.

Any nix file that is referenced this way will receive the attrset `{ repoRoot, inputs, pkgs, system, lib }`, just like [`mkFlake.<in>.outputs`](#mkflakeinoutputs).

Using the `repoRoot` argument is optional, but it has the advantage of not having to thread the standard arguments (especially `pkgs` and `inputs`) all over the place.

### `inputs`

Your flake inputs as defined in [`mkFlake.<in>.inputs`](#mkflakeininputs).

Note that these `inputs` have been de-systemized against the current system.

This means that you can use the following syntax:
```nix
inputs.n2c.packages.nix2container
inputs.self.packages.foo
```

In addition to the usual syntax which mentions `system` explicitely.
```nix 
inputs.n2c.packages.x86_64-linux.nix2container
inputs.self.packages.x86_64-darwin.foo
```

#### `pkgs`

A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your [`mkFlake.<in>.systems`](#mkflakeinsystems), and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

A `nixpkgs` is also available at `inputs.nixpkgs.legacyPackages` but that should *not* be used because it doesn't have the required overlays.

You may reference `pkgs` freely to get to the legacy packages.

#### `system`

This is just `pkgs.stdenv.system`, which is likely to be used often.

#### `lib`

This is just `pkgs.lib` plus the `iogx` attrset, which contains library functions and utilities.

In here you will find the following: 
```nix 
lib.iogx.mkHaskellProject {}
lib.iogx.mkShell {}
```


---

### `mkFlake.<in>.repoRoot`

**Type**: path

**Default**: `null`


**Example**: `./.`


The root of your repository.

If not set, this will default to the folder containing the `flake.nix` file, using `inputs.self`.


---

### `mkFlake.<in>.systems`

**Type**: list of (one of "x86_64-linux", "x86_64-darwin", "aarch64-darwin", "aarch64-linux")

**Default**: `[ "x86_64-linux" "x86_64-darwin" ]`




The systems you want to build for.

The [`mkFlake.<in>.outputs`](#mkflakeinoutputs) function will be called once for each system.


---

### `mkHaskellProject`

**Type**: core API function



**Example**: 
```nix
# project.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  cabalProject = lib.iogx.mkHaskellProject {
    mkShell = repoRoot.nix.make-shell;

    readTheDocs.siteFolder = "doc/read-the-docs-site";
    
    combinedHaddock.enable = true;
    
    cabalProjectArgs = {

      compiler-nix-name = "ghc8107";

      flake.variants.FOO = {
        compiler-nix-name = "ghc927";
      };
    };
  };
in 
[
  {
    inherit cabalProject;
  }
  {
    hydraJobs.FOO = cabalProject.projectVariants.FOO.iogx.hydraJobs;
  }
]

```


The `lib.iogx.mkHaskellProject` function takes an attrset of options and returns a `cabalProject` with the `iogx` overlay.

In this document:
  - Options for the input attrset are prefixed by `mkHaskellProject.<in>`.
  - The returned attrset contains the attributes prefixed by `mkHaskellProject.<out>.iogx`.


---

### `mkHaskellProject.<in>.cabalProject`

**Type**: raw value

**Default**: `{ }`


**Example**: 
```nix
# project.nix 
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkHaskellProject {
  cabalProject = pkgs.haskell-nix.cabalProject' {
    name = "my-project"; 
    src = ./.; # Must contain the cabal.project file
    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
    };
    compiler-nix-name = "ghc8107";
    flake.variants.profiled = {
      modules = [{ 
        enableProfiling = true; 
        enableLibraryProfiling = true; 
      }];
    };
    flake.variants.ghc928 = {
      compiler-nix-name = "ghc928";
    };
    modules = [];
    cabalProjectLocal = "";
  };
};

```


The original `cabalProject`. 

You most likely want to get one using [`haskell.nix:cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=cabalProjec#cabalproject).

You should use `flake.variants` to provide support for profiling, different GHC versions, and any other additional configuration.

The variants will be available in [`mkHaskellProject.<out>.variants`](#mkhaskellprojectoutvariants).


---

### `mkHaskellProject.<in>.combinedHaddock`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  packages = [ ];
  prologue = "";
}
```


**Example**: 
```nix
# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {
    combinedHaddock = {
      enable = system == "x86_64-linux";
      packages = [ "foo" "bar" ];
      prologue = "This is the prologue.";
    };
  };
in 
[
  {
    inherit (project) cabalProject;
  }
  {
    packages.combined-haddock = project.combined-haddock;
  }
]

```


Configuration for a combined Haddock.

When enabled, your [`mkHaskellProject.<in>.readTheDocs`](#mkhaskellprojectinreadthedocs) site will have access to Haddock symbols for your Haskell packages.

Combining Haddock artifacts takes a significant amount of time and may slow down CI.

The combined Haddock will be available in:
- [`mkHaskellProject.<out>.combined-haddock`](#mkhaskellprojectoutcombined-haddock)
- [`mkHaskellProject.<out>.cross.<name>.combined-haddock`](#mkhaskellprojectoutcrossnamecombined-haddock)


---

### `mkHaskellProject.<in>.combinedHaddock.enable`

**Type**: boolean

**Default**: `false`




Whether to enable combined haddock for your project.


---

### `mkHaskellProject.<in>.combinedHaddock.packages`

**Type**: list of string

**Default**: `[ ]`




The list of cabal package names to include in the combined Haddock.


---

### `mkHaskellProject.<in>.combinedHaddock.prologue`

**Type**: string

**Default**: `""`




A string acting as prologue for the combined Haddock.


---

### `mkHaskellProject.<in>.includeMingwW64HydraJobs`

**Type**: boolean

**Default**: `false`




When set to `true` then [`mkHaskellProject.<out>.flake`](#mkhaskellprojectoutflake) will include `hydraJobs.mingwW64`
for your `cabalProject.projectCross.mingwW64`.


---

### `mkHaskellProject.<in>.readTheDocs`

**Type**: submodule

**Default**: 
```nix
{
  siteFolder = null;
}
```


**Example**: 
```nix
# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {
    readTheDocs.siteFolder = "doc/read-the-docs-site";
  };
in 
[
  {
    inherit (proejct) cabalProject;
  }
  {
    packages.read-the-docs-site = project.read-the-docs-site;
  }
]

```


Configuration for your [`read-the-docs`](https://readthedocs.org) site. 

If no site is required, this option can be omitted.

The shells generated by [`mkHaskellProject.<in>.shellArgs`](#mkhaskellprojectinshellargs) will be 
augmented with several scripts to make developing your site easier, 
grouped under the tag `read-the-docs`.

The Read The Docs site derivation will be available in:
- [`mkHaskellProject.<out>.read-the-docs-site`](#mkhaskellprojectoutread-the-docs-site)
- [`mkHaskellProject.<out>.variants.<name>.read-the-docs-site`](#mkhaskellprojectoutvariantsnameread-the-docs-site)


---

### `mkHaskellProject.<in>.readTheDocs.enable`

**Type**: boolean

**Default**: `false`




Whether to enable support for a Read The Docs site.


---

### `mkHaskellProject.<in>.readTheDocs.siteFolder`

**Type**: string



**Example**: 
```nix
# project.nix
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkHaskellProject {
  readTheDocs.siteFolder = "./doc/read-the-docs-site";
}

```


A Nix string representing a path, relative to the repository root, to your site folder containing the `conf.py` file.


---

### `mkHaskellProject.<in>.readTheDocs.sphinxToolchain`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# project.nix
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkHaskellProject {
  readTheDocs = {
    enable = true;
    siteFolder = "./doc/read-the-docs-site";
    sphinxToolchain = pkgs.python3.withPackages (py: [
      repoRoot.nix.ext.sphinxcontrib-bibtex
      repoRoot.nix.ext.sphinx-markdown-tables
      repoRoot.nix.ext.sphinxemoji
      repoRoot.nix.ext.sphinxcontrib-haddock
      repoRoot.nix.ext.sphinxcontrib-domaintools
      py.sphinxcontrib_plantuml
      py.sphinx-autobuild
      py.sphinx
      py.sphinx_rtd_theme
      py.recommonmark
    ]);
  };
}

```


A python environment with the required packages to build your site using sphinx.

Normally you don't need to override this.


---

### `mkHaskellProject.<in>.shellArgs`

**Type**: function that evaluates to a(n) (attribute set)

**Default**: `<function>`




Arguments for [`mkShell`](#mkshell).

This is a function that is called once with the [`mkHaskellProject.<in>.cabalProject`](#mkhaskellprojectincabalproject) 
and then once for each project variant. 

Internally these `shellArgs` are passed to [`mkShell`](#mkshell).

The shells will be available in:
- [`mkHaskellProject.<out>.devShell`](#mkhaskellprojectoutdevshell).
- [`mkHaskellProject.<out>.variants.<name>.devShell`](#mkhaskellprojectoutvariantsnamedevshell).


---

### `mkHaskellProject.<out>.iogx`

**Type**: submodule



**Example**: 
```nix
# flake.nix 
{
  outputs = inputs: inputs.iogx.lib.mkFlake {
    outputs = import ./outputs.nix;
  };
}

# outputs.nix
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {
    cabalProject = {
      compiler-nix-name = "ghc8107";

      flake.variants.profiled = { 
        modules = [{ 
          enableProfiling = true; 
          enableLibraryProfiling = true; 
        }];
      };

      flake.variants.ghc928 = { 
        compiler-nix-name = "ghc928";
      };
    }
  };
in 
[
  {
    inherit (project) cabalProject;
  }
  {
    pacakges.read-the-docs-site-ghc8107 = project.read-the-docs-site;
    pacakges.read-the-docs-site-ghc928 = project.variants.ghc928.read-the-docs-site;
  }
  {
    devShells.default = project.devShell;
    devShells.profiled = project.variants.profiled.devShell;
    devShells.ghc928 = project.variants.ghc928.devShell;
  }
  {
    hydraJobs.ghc8107 = project.hydraJobs;
    hydraJobs.ghc928 = project.variants.ghc928.hydraJobs;
  }
]

```


This in an attrset containing all the derivations for your project.

You will want to consume this value in your flake [`mkFlake.<in>.outputs`](#mkflakeinoutputs), as shown in the example above.


---

### `mkHaskellProject.<out>.iogx.apps`

**Type**: attribute set





A attrset containing the cabal executables, testsuites and benchmarks.

The keys are the cabal target names, and the values are the program paths.

IOGX will fail to evaluate if some of you cabal targets have the same name.


---

### `mkHaskellProject.<out>.iogx.checks`

**Type**: attribute set





A attrset containing the cabal testsuites.

When these derivations are **built**, the actual tests will be run as part of the build.

The keys are the cabal target names, and the values are the derivations.

IOGX will fail to evaluate if some of you cabal targets have the same name.


---

### `mkHaskellProject.<out>.iogx.combined-haddock`

**Type**: package





The derivation for your [`mkHaskellProject.<in>.combinedHaddock`](#mkhaskellprojectincombinedhaddock).


---

### `mkHaskellProject.<out>.iogx.cross`

**Type**: attribute set



**Example**: 
```nix
# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {};
in 
[
  { 
    projectMingwW64 = project.cross.mingwW64.cabalProject;
    projectMusl64 = project.cross.musl64.cabalProject;

    hydraJobs.mingwW64 = project.cross.mingwW64.hydraJobs;
    hydraJobs.musl64 = project.cross.musl64.hydraJobs;
  } 
]

```


This attribute contains cross-compilation variants for your project.

Each variant only has two attributes: 
- `cabalProject` the original project coming from `projectCross.<name>`
- `hydraJobs` that can be included directly in your flake outputs


---

### `mkHaskellProject.<out>.iogx.devShell`

**Type**: package





The `devShell` as provided by your implementation of [`mkHaskellProject.<in>.shellArgs`](#mkhaskellprojectinshellargs).


---

### `mkHaskellProject.<out>.iogx.flake`

**Type**: attribute set



**Example**: 
```nix
# flake.nix 
{
  outputs = inputs: inputs.iogx.lib.mkFlake {
    outputs = inherit ./outputs.nix;
  };
}

# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {};
in 
[
  (
    project.flake
  )
]

```


An attribute set that can be included in your [`mkFlake.<in>.outputs`](#mkflakeinoutputs) directly.

It contains all the derivations for your project, but does not include project variants.

If you set [`mkHaskellProject.<in>.includeMingwW64HydraJobs`](#mkhaskellprojectinincludemingww64hydrajobs) to `true`, then 
this attrset will also include `hydraJobs.mingwW64`.

This also automatically adds the `required` job using [`mkHydraRequiredJob`](#mkhydrarequiredjob).

- `cabalProject` = [`mkHaskellProject.<out>.cabalProject`](#mkhaskellprojectoutcabalproject)
- `devShells.default` = [`mkHaskellProject.<out>.devShell`](#mkhaskellprojectoutdevshell)
- `packages.*` = [`mkHaskellProject.<out>.packages`](#mkhaskellprojectoutpackages)
- `packages.combined-haddock` = [`mkHaskellProject.<out>.combined-haddock`](#mkhaskellprojectoutcombined-haddock)
- `packages.read-the-docs-site` = [`mkHaskellProject.<out>.read-the-docs-site`](#mkhaskellprojectoutread-the-docs-site)
- `packages.pre-commit-check` = [`mkHaskellProject.<out>.pre-commit-check`](#mkhaskellprojectoutpre-commit-check)
- `apps.*` = [`mkHaskellProject.<out>.apps`](#mkhaskellprojectoutapps)
- `checks.*` = [`mkHaskellProject.<out>.checks`](#mkhaskellprojectoutchecks)
- `hydraJobs.*` = [`mkHaskellProject.<out>.hydraJobs`](#mkhaskellprojectouthydrajobs)
- `hydraJobs.combined-haddock` = [`mkHaskellProject.<out>.combined-haddock`](#mkhaskellprojectoutcombined-haddock)
- `hydraJobs.read-the-docs-site` = [`mkHaskellProject.<out>.read-the-docs-site`](#mkhaskellprojectoutread-the-docs-site) 
- `hydraJobs.pre-commit-check` = [`mkHaskellProject.<out>.pre-commit-check`](#mkhaskellprojectoutpre-commit-check) 
- `hydraJobs.mingwW64` = [`mkHaskellProject.<out>.cross.mingwW64.hydraJobs`](#mkhaskellprojectoutcrossmingww64hydrajobs)
- `hydraJobs.required` = [`mkHydraRequiredJob`](#mkhydrarequiredjob)


---

### `mkHaskellProject.<out>.iogx.hydraJobs`

**Type**: attribute set





A jobset containing `packages`, `checks`, `devShells.default` and `haskell.nix`'s `plan-nix` and `roots`.

The `devShell` comes from your implementation of [`mkHaskellProject.<in>.shellArgs`](#mkhaskellprojectinshellargs).

This attrset does not contain:
- [`mkHaskellProject.<out>.combined-haddock`](#mkhaskellprojectoutcombined-haddock)
- [`mkHaskellProject.<out>.read-the-docs-site`](#mkhaskellprojectoutread-the-docs-site)
- [`mkHaskellProject.<out>.pre-commit-check`](#mkhaskellprojectoutpre-commit-check)

If you need those you can use [`mkHaskellProject.<out>.iogx.defaultFlakeOutputs`](#mkhaskellprojectoutiogxdefaultflakeoutputs), or you can reference them directly from the `iogx` attrset.


---

### `mkHaskellProject.<out>.iogx.packages`

**Type**: attribute set





A attrset containing the cabal executables, testsuites and benchmarks.

The keys are the cabal target names, and the values are the derivations.

IOGX will fail to evaluate if some of you cabal targets have the same name.


---

### `mkHaskellProject.<out>.iogx.pre-commit-check`

**Type**: package





The derivation for the [`mkShell.<in>.preCommit`](#mkshellinprecommit) coming from [`mkHaskellProject.<in>.shellArgs`](#mkhaskellprojectinshellargs).


---

### `mkHaskellProject.<out>.iogx.read-the-docs-site`

**Type**: package





The derivation for your [`mkHaskellProject.<in>.readTheDocs`](#mkhaskellprojectinreadthedocs).


---

### `mkHaskellProject.<out>.iogx.variants`

**Type**: attribute set



**Example**: 
```nix
# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  project = lib.iogx.mkHaskellProject {
    cabalProject = pkgs.haskell-nix.cabalProject' {
      flake.variants.ghc928 = {};
      flake.variants.profiled = {};
    };
  };
in 
[
  { 
    hydraJobs.normal = project.hydraJobs;
    hydraJobs.profiled = project.variants.profiled.hydraJobs;
    hydraJobs.ghc928 = project.variants.ghc928.hydraJobs;

    packages.read-the-docs-normal = project.read-the-docs-site;
    packages.read-the-docs-profiled = project.variants.profiled.read-the-docs-site;
    packages.read-the-docs-ghc928 = project.variants.ghc928.read-the-docs-site;

    hydraJobs.ghc928-mingwW64 = project.variants.ghc928.cross.mingwW64.hydraJobs;
  } 
]

```


This attribute contains the variants for your project, 
as defined in your [`mkHaskellProject.<in>.cabalProject`](#mkhaskellprojectincabalproject)`.flake.variants`.

Each variant has exaclty the same attributes as the main project.

See the example above for more information.


---

### `mkShell`

**Type**: core API function



**Example**: 
```nix
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkShell {
  name = "dev-shell";
  packages = [ pkgs.hello ];
  env = {
    FOO = "bar";
  };
  scripts = {
    foo = {
      description = "";
      group = "general";
      enabled = false;
      exec = ''
        echo "Hello, World!"
      '';
    };
  };
  shellHook = "";
  preCommit = {
    shellcheck.enable = true;
  };
  tools.haskellCompilerVersion = "ghc8103";
};

```


The `lib.iogx.mkShell` function takes an attrset of options and returns a normal `devShell` with an additional attribute named [`mkShell.<out>.pre-commit-check`](#mkshelloutpre-commit-check).

In this document:
  - Options for the input attrset are prefixed by `mkShell.<in>`.
  - The returned attrset contains the attributes prefixed by `mkShell.<out>`.


---

### `mkShell.<in>.env`

**Type**: lazy attribute set of raw value

**Default**: `{ }`


**Example**: 
```nix
env = {
  PGUSER = "postgres";
  THE_ANSWER = 42;
};

```


Custom environment variables. 

Considering the example above, the following bash code will be executed every time you enter the shell:

```bash 
export PGUSER="postgres"
export THE_ANSWER="42"
```


---

### `mkShell.<in>.name`

**Type**: string

**Default**: `"nix-shell"`




This field will be used as the shell's derivation name and it will also be used to fill in the default values for [`mkShell.<in>.prompt`](#mkshellinprompt) and [`mkShell.<in>.welcomeMessage`](#mkshellinwelcomemessage).


---

### `mkShell.<in>.packages`

**Type**: list of package

**Default**: `[ ]`




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

If you `cabalProject` (coming from [`mkHaskellProject`](#mkhaskellproject)) is in scope, you could use `hsPkgs` to obtain some useful binaries:
```nix
packages = [
  cabalProject.hsPkgs.cardano-cli.components.exes.cardano-cli
  cabalProject.hsPkgs.cardano-node.components.exes.cardano-node
];
```

Be careful not to reference your project's own cabal packages via `hsPkgs`. 

If you do, then `nix develop` will build your project every time you enter the shell, and it will fail to do so if there are Haskell compiler errors.


---

### `mkShell.<in>.preCommit`

**Type**: submodule

**Default**: `{ }`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkShell {
  preCommit = {
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
    optipng.enable = false;
    optipng.extraOptions = "";
    fourmolu.enable = false;
    fourmolu.extraOptions = "";
    hlint.enable = false;
    hlint.extraOptions = "";
    purs-tidy.enable = false;
    purs-tidy.extraOptions = "";
  };
}

```


Configuration for pre-commit hooks, including code formatters and linters.

These are fed to [`pre-commit-hooks`](https://github.com/cachix/pre-commit-hooks.nix), which is run whenever you `git commit`.

The `pre-commit` executable will be made available in the shell.

All the hooks are disabled by default.

It is sufficient to set the `enable` flag to `true` to make the hook active.

When enabled, some hooks expect to find a configuration file in the root of the repository:

| Hook Name | Config File | 
| --------- | ----------- |
| `stylish-haskell` | `.stylish-haskell.yaml` |
| `editorconfig-checker` | `.editorconfig` |
| `fourmolu` | `fourmolu.yaml` (note the missing dot `.`) |
| `hlint` | `.hlint.yaml` |
| `hindent` | `.hindent.yaml` |

Currently there is no way to change the location of the configuration files.

Each tool knows which file extensions to look for, which files to ignore, and how to modify the files in-place.


---

### `mkShell.<in>.preCommit.cabal-fmt`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `cabal-fmt` pre-commit hook.


---

### `mkShell.<in>.preCommit.cabal-fmt.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.cabal-fmt.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.cabal-fmt.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.editorconfig-checker`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `editorconfig-checker` pre-commit hook.


---

### `mkShell.<in>.preCommit.editorconfig-checker.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.editorconfig-checker.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.editorconfig-checker.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.fourmolu`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `fourmolu` pre-commit hook.


---

### `mkShell.<in>.preCommit.fourmolu.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.fourmolu.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.fourmolu.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.hlint`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `hlint` pre-commit hook.


---

### `mkShell.<in>.preCommit.hlint.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.hlint.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.hlint.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.nixpkgs-fmt`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `nixpkgs-fmt` pre-commit hook.


---

### `mkShell.<in>.preCommit.nixpkgs-fmt.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.nixpkgs-fmt.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.nixpkgs-fmt.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.optipng`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `optipng` pre-commit hook.


---

### `mkShell.<in>.preCommit.optipng.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.optipng.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.optipng.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.prettier`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `prettier` pre-commit hook.


---

### `mkShell.<in>.preCommit.prettier.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.prettier.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.prettier.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.purs-tidy`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `purs-tidy` pre-commit hook.


---

### `mkShell.<in>.preCommit.purs-tidy.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.purs-tidy.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.purs-tidy.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.shellcheck`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `shellcheck` pre-commit hook.


---

### `mkShell.<in>.preCommit.shellcheck.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.shellcheck.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.shellcheck.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.preCommit.stylish-haskell`

**Type**: submodule

**Default**: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




The `stylish-haskell` pre-commit hook.


---

### `mkShell.<in>.preCommit.stylish-haskell.enable`

**Type**: boolean

**Default**: `false`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = system != "x86_64-darwin";
  };
}

```


Whether to enable this pre-commit hook.

If `false`, the hook will not be installed.

If `true`, the hook will become available in the shell: 
```bash 
pre-commit run <hook-name>
```


---

### `mkShell.<in>.preCommit.stylish-haskell.extraOptions`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.extraOptions = "--no-tabular";
    fourmolu.enable = false;
    fourmolu.extraOptions = "-o -XTypeApplications -o XScopedTypeVariables";
  };
}

```


Extra command line options to be passed to the hook.

Each hooks knows how run itself, and will be called with the correct command line arguments.

However you can *append* additional options to a tool's command by setting this field.


---

### `mkShell.<in>.preCommit.stylish-haskell.package`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  preCommit = {
    cabal-fmt.enable = true;
    cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
  };
}

```


The package that provides the hook.

The `nixpkgs.lib.getExe` function will be used to extract the program to run.

If unset or `null`, the default package will be used.

In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.


---

### `mkShell.<in>.prompt`

**Type**: null or string

**Default**: `null`




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
This field is optional and defaults to the familiar green `nix-shell` prompt.


---

### `mkShell.<in>.scripts`

**Type**: lazy attribute set of (submodule)

**Default**: `{ }`


**Example**: 
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


Custom scripts for your shell.

`scripts` is an attrset where each attribute name is the script name each the attribute value is an attrset.

The attribute names (`foobar` and `waz` in the example above) will be available in your shell as commands under the same name.


---

### `mkShell.<in>.scripts.<name>.description`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      description = "Short description for script foo";
      exec = "#";
    };
  };
}

```


A string that will appear next to the script name when printed.


---

### `mkShell.<in>.scripts.<name>.enable`

**Type**: boolean

**Default**: `true`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      exec = ''
        echo "I only run on Linux."
      '';
    };
  };
}

```


Whether to enable this script.

This can be used to include scripts conditionally.


---

### `mkShell.<in>.scripts.<name>.exec`

**Type**: string



**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      exec = ''
        echo "Hello, world!"
      '';
    };
  };
}

```


Bash code to be executed when the script is run.

This field is required.


---

### `mkShell.<in>.scripts.<name>.group`

**Type**: string

**Default**: `""`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      group = "devops";
      exec = "#";
    };
  };
}

```


A string to tag the script.

This will be used to group scripts together so that they look prettier and more organized when listed. 


---

### `mkShell.<in>.shellHook`

**Type**: string

**Default**: `""`


**Example**: 
```nix
shellHook = ''
  # Bash code to be executed when you enter the shell.
  echo "I'm inside the shell!"
'';

```


Standard nix `shellHook`, to be executed every time you enter the shell.


---

### `mkShell.<in>.tools`

**Type**: submodule

**Default**: `{ }`




An attrset of packages to be made available in the shell.

This can be used to override the default derivations used by IOGX.

The value of [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to determine the version of the Haskell tools (e.g. `cabal-install` or `stylish-haskell`).


---

### `mkShell.<in>.tools.cabal-fmt`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.cabal-fmt = repoRoot.nix.patched-cabal-fmt;
}

```


A package that provides the `cabal-fmt` executable.

If unset or `null`, a default `cabal-fmt` will be provided, which is independent of [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion).


---

### `mkShell.<in>.tools.cabal-install`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.cabal-install = repoRoot.nix.patched-cabal-install;
}

```


A package that provides the `cabal-install` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.tools.editorconfig-checker`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.editorconfig-checker = repoRoot.nix.patched-editorconfig-checker;
}

```


A package that provides the `editorconfig-checker` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.fourmolu`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.fourmolu = repoRoot.nix.patched-fourmolu;
}

```


A package that provides the `fourmolu` executable.

If unset or `null`, a default `fourmolu` will be provided, which is independent of [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion).


---

### `mkShell.<in>.tools.ghcid`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.ghcid = repoRoot.nix.patched-ghcid;
}

```


A package that provides the `ghcid` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.tools.haskell-language-server`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.haskell-language-server = repoRoot.nix.patched-haskell-language-server;
}

```


A package that provides the `haskell-language-server` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.tools.haskell-language-server-wrapper`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.haskell-language-server-wrapper = repoRoot.nix.pathced-haskell-language-server-wrapper;
}

```


A package that provides the `haskell-language-server-wrapper` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.tools.haskellCompilerVersion`

**Type**: null or one of "ghc8107", "ghc928", "ghc927", "ghc962", "ghc810", "ghc92", "ghc96"

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.haskellCompilerVersion = "ghc8107";
}

```


The haskell compiler version.

This determines the version of other tools like `cabal-install` and `haskell-language-server`.

This option must be set to a value.

If you have a `cabalProject`, you should use its `compiler-nix-name`:
```nix
# shell.nix
{ repoRoot, inputs, pkgs, lib, system }:

cabalProject: 

lib.iogx.mkShell {
  tools.haskellCompilerVersion = cabalProject.args.compiler-nix-name;
}
```

The example above will use the same compiler version as your project.

IOGX does this automatically when creating a shell with [`mkHaskellProject.<in>.shellArgs`](#mkhaskellprojectinshellargs).


---

### `mkShell.<in>.tools.hlint`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.hlint = repoRoot.nix.patched-hlint;
}

```


A package that provides the `hlint` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.tools.nixpkgs-fmt`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.nixpkgs-fmt = repoRoot.nix.patched-nixpkgs-fmt;
}

```


A package that provides the `nixpkgs-fmt` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.optipng`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.optipng = repoRoot.nix.patched-optipng;
}

```


A package that provides the `optipng` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.prettier`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.prettier = repoRoot.nix.patched-prettier;
}

```


A package that provides the `prettier` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.purs-tidy`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.purs-tidy = repoRoot.nix.patched-purs-tidy;
}

```


A package that provides the `purs-tidy` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.shellcheck`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.shellcheck = repoRoot.nix.patched-shellcheck;
}

```


A package that provides the `shellcheck` executable.

If unset or `null`, the most recent version available will be used.


---

### `mkShell.<in>.tools.stylish-haskell`

**Type**: null or package

**Default**: `null`


**Example**: 
```nix
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.stylish-haskell = repoRoot.nix.patched-stylish-haskell;
}

```


A package that provides the `stylish-haskell` executable.

If unset or `null`, [`mkShell.<in>.tools.haskellCompilerVersion`](#mkshellintoolshaskellcompilerversion) will be used to select a suitable derivation.


---

### `mkShell.<in>.welcomeMessage`

**Type**: null or string

**Default**: `null`




When entering the shell, this welcome message will be printed.

The same caveat about escaping back slashes in [`mkShell.<in>.prompt`](#mkshellinprompt) applies here.

This field is optional and defaults to a simple welcome message using the [`mkShell.<in>.name`](#mkshellinname) field.


---

### `mkShell.<out>.pre-commit-check`

**Type**: package



**Example**: 
```nix
{ repoRoot, inputs, pkgs, lib, system }:
let
  shell = lib.iogx.mkShell {};
in 
[
  {
    devShells.foo = shell;
    packages.pre-commit-check = shell.pre-commit-check;
    hydraJobs.pre-commit-check = shell.pre-commit-check;
  }
]

```


A derivation that when built will run all the installed shell hooks.

The hooks are configured in [`mkShell.<in>.preCommit`](#mkshellinprecommit).

This derivation can be included in your `packages` and in `hydraJobs`.


