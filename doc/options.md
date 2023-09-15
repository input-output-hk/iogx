# Options Reference 

1. [`inputs.iogx.lib.mkFlake`](#TODO) 
  - Makes the final flake outputs.
2. [`pkgs.lib.iogx.mkProject`](#TODO) 
  - Makes a [`haskell.nix`](https://github.com/input-output-hk/haskell.nix) project decorated with the `iogx` overlay.
3. [`pkgs.lib.iogx.mkShell`](#TODO) 
  - Makes a `devShell` with `pre-commit-check` and tools.

---

<h2>`mkFlake`</h2> :: core API function


    
```nix
# Example:
# flake.nix
outputs = inputs: inputs.iogx.lib.mkFlake {
  inherit inputs;
  repoRoot = ./.;
  systems = [ "x86_64-linux" "x86_64-darwin" ];
  outputs = { repoRoot, inputs, pkgs, lib, system }: [];
};

```
The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

In this document:
  - Options for the input attrset are prefixed by `mkFlake.<in>`.
  - The returned attrset contans attributes prefixed by `mkFlake.<out>`.


---

<h2>`mkFlake.<in>.debug`</h2> :: boolean


```nix
# Default:
false
```
    
If enabled, IOGX will trace debugging info to standard output.


---

<h2>`mkFlake.<in>.flake`</h2> :: attribute set


```nix
# Default:
{ }
```
    
```nix
# Example:
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

You can place additional flake outputs here, which will be recursively updated with the outputs from #TODOmkFlake.outputs.

This is a good place to put system-independent values like a `lib` attrset or pure Nix values.


---

<h2>`mkFlake.<in>.inputs`</h2> :: attribute set


    
Your flake inputs.

You want to do `inherit inputs;` here.


---

<h2>`mkFlake.<in>.nixpkgsArgs`</h2> :: attribute set


```nix
# Default:
{ 
  config = { }; 
  overlays = [ ]; 
}

```
    
Internally, IOGX calls `import inputs.nixpkgs {}`.

Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.


---

<h2>`mkFlake.<in>.outputs`</h2> :: function that evaluates to a(n) list of (attribute set)


    
```nix
# Example:
{ repoRoot, inputs, pkgs, lib, system }:
[
  {
    cabalProject = lib.iogx.mkProject {};
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
A function that is called once for each #TODOsystem.

This is the most important option as it will determine your flake outputs.

The function receives an attrset and must return a list of attrsets.

The returned attrsets are recursively merged top-to-bottom. 

Each of the input attributes is documented below:

#### `repoRoot`

Ordinarily you would use the `import` keyword to import nix files, but you can use the `repoRoot` variable instead.

`repoRoot` is an attrset that can be used to reference the contents of your repository folder instead of using the `import` keyword.

Its value is set to the path in #TODOmkFlake.repoRoot.

For example, if this is your top-level folder:
```
* src 
  - Main.hs 
cabal.project 
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
{ repoRoot, pkgs, system, lib, ... }:
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

Any nix file that is referenced this way will receive the attrset `{ repoRoot, inputs, pkgs, system, lib }`, just like the `outputs` option.

Using the `repoRoot` argument is optional, but it has the advantage of not having to thead the standard arguments (especially `pkgs` and `inputs`) all over the place.

### `inputs`

Your original flake inputs as defined in #TODOmkFlake.inputs.

Note that the inputs have been de-systemized against the current system.

This means that you can use the following syntax:
```nix
inputs.n2c.packages.nix2container
inputs.self.packages.foo
```

In addition to the usual syntax which mentions `system` explicitely.
```nix 
inputs.n2c.packages.x86_64-linux.nix2container
inputs'.self.packages.x86_64-darwin.foo
```

#### `pkgs`

A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your supported systems, and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

A `nixpkgs` is also available at `inputs.nixpkgs.legacyPackages` but that should *not* be used because it doesn't have the required overlays.

You may reference `pkgs` freely to get to the legacy packages.

#### `system`

This is just `pkgs.stdenv.system`, which is likely to be used often.

#### `lib`

This is just `pkgs.lib` plus the `iogx` attrset, which contains library functions and utilities.

In here you will find the following: 
```nix 
lib.iogx.mkProject {}
lib.iogx.mkShell {}
```


---

<h2>`mkFlake.<in>.repoRoot`</h2> :: path


```nix
# Default:
null
```
    
```nix
# Example:
/nix/store/977dra06rpply60c48jqzkclbrf2l5f4-source/src/boot
```
The root of your repository.

If not set, this will default to the folder containing the flake.nix file, using `inputs.self`.


---

<h2>`mkFlake.<in>.systems`</h2> :: list of (one of "x86_64-linux", "x86_64-darwin", "aarch64-darwin", "aarch64-linux")


```nix
# Default:
[ "x86_64-linux" "x86_64-darwin" ]
```
    
The systems you want to build for.


---

<h2>`mkFlake.<out>."<flake>"`</h2> :: attribute set


```nix
# Default:
{ }
```
    
Test

---

<h2>`mkProject`</h2> :: core API function


    
```nix
# Example:
{ repoRoot, inputs, pkgs, lib, system }:
let 
  cabalProject = lib.iogx.mkProject {
    cabalProjectArgs = {
      compiler-nix-name = "ghc8107";
      flake.variants.FOO = {
        modules = [{..}];
      };
    };
    mkShell = repoRoot.nix.make-shell;
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
The `pkgs.lib.iogx.mkProject` function takes an attrset of options and returns a `cabalProject` with the `iogx` overlay.

In this document:
  - Options for the input attrset are prefixed by `mkProject.<in>`.
  - The returned attrset contans attributes prefixed by `mkShell.<out>`.


---

<h2>`mkProject.<in>.cabalProjectArgs`</h2> :: raw value


```nix
# Default:
{ }
```
    
```nix
# Example:
# cabal-project.nix 
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkProject {
  cabalProjectArgs = {
    src = ./.; # Optional (must contain the cabal.project file)
    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
    };
    compiler-nix-name = "ghc8197";
    flake.variants = {
      profiled = {
        modules = [{ enableProfiling = true; }];
      };
      ghc928 = {
        compiler-nix-name = "ghc928";
      };
    };
    modules = [];
  };
};

```
The very arguments that will be passed to `haskell.nix:cabalProject'`.

The `src` and `inputMap` arguments can be omitted. 


---

<h2>`mkProject.<in>.combinedHaddock`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  packages = [ ];
  prologue = "";
}
```
    
```nix
# Example:
# outputs.nix 
{ repoRoot, inputs, pkgs, lib, system }:
let 
  cabalProject = lib.iogx.mkProject {
    combinedHaddock = {
      enable = system == "x86_64-linux";
      packages = [ "foo" "bar" ];
      prologue = "This is the prologue.";
    };
  };
in 
[
  {
    inherit cabalProject;
  }
]

```
Configuration for a combined Haddock.

When enabled, your #TODO nix/read-the-docs.nix site will have access to Haddock symbols for your Haskell packages.

Combining Haddock artifacts takes a significant amount of time and may slow do CI.

The combined Haddock will only be generated for your default project, not for any of the variants.


---

<h2>`mkProject.<in>.combinedHaddock.enable`</h2> :: boolean


```nix
# Default:
false
```
    
Whether to enable combined haddock for your project.


---

<h2>`mkProject.<in>.combinedHaddock.packages`</h2> :: list of string


```nix
# Default:
[ ]
```
    
The list of cabal package names to include in the combined Haddock.


---

<h2>`mkProject.<in>.combinedHaddock.prologue`</h2> :: string


```nix
# Default:
""
```
    
A string acting as prologue for the combined Haddock.


---

<h2>`mkProject.<in>.mkShell`</h2> :: function that evaluates to a(n) (attribute set)


```nix
# Default:
<function>
```
    
This function will be called to create a shell for your project variants.

It receives each project as an argument and must return a #TODOmkShell.mkShell-IN-submodule attrset.


---

<h2>`mkProject.<in>.readTheDocs`</h2> :: submodule


```nix
# Default:
{
  siteFolder = null;
}
```
    
```nix
# Example:
{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkProject {
  readTheDocs.siteFolder = "./doc/read-the-docs-site";
}

```
Configuration for your [`read-the-docs`](https://readthedocs.org) site. 

If no site is required, this option can be omitted.

The shells generated by #TODOmkShell will be augmented with several scripts to make developing your site easier, grouped under the tag `read-the-docs`.

In addition, a `read-the-docs-site` derivation will be added to the #TODOiogx overlay.


---

<h2>`mkProject.<in>.readTheDocs.siteFolder`</h2> :: null or string


```nix
# Default:
null
```
    
```nix
# Example:
# cabal-project.nix

{ repoRoot, inputs, pkgs, lib, system }:

lib.iogx.mkProject {
  readTheDocs.siteFolder = "./doc/read-the-docs-site";
}

```
A Nix string representing a path, relative to the repository root, to your site folder containing the `conf.py` file.

If no site is required you can set this field to `null`, or omit the #TODO`readTheDocs` option entirely. 


---

<h2>`mkProject.<out>.apps`</h2> :: attribute set


    
Only the project's executables end up here.

Their name has been shortened to the cabal target name.


---

<h2>`mkProject.<out>.checks`</h2> :: attribute set


    
Only the project's executables end up here.

Their name has been shortened to the cabal target name.


---

<h2>`mkProject.<out>.defaultFlakeOutputs`</h2> :: attribute set


    
Test


---

<h2>`mkProject.<out>.devShell`</h2> :: package


    
The devShell as provided by `mkShell`.


---

<h2>`mkProject.<out>.flake`</h2> :: attribute set


    
The *original* flake outputs provided by haskell.nix.

In general you don't need this.


---

<h2>`mkProject.<out>.hydraJobs`</h2> :: attribute set


    
Test


---

<h2>`mkProject.<out>.packages`</h2> :: attribute set


    
Only the project's executables end up here.

Their name has been shortened to the cabal target name.


---

<h2>`mkProject.<out>.pre-commit-check`</h2> :: package


    
Test


---

<h2>`mkProject.<out>.read-the-docs-site`</h2> :: package


    
Test


---

<h2>`mkShell`</h2> :: core API function


    
```nix
# Example:
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
      exec = \'\'
        echo "Hello, World!"
      \'\';
    };
  };
  shellHook = "";
  preCommit = {
    shellcheck.enable = true;
  };
  tools.haskellCompiler = "ghc8103";
};

```
The `pkgs.lib.iogx.mkFlake` function takes an attrset of options and returns an attrset containing the #TODOdevShell and the #TODOpre-commit-check derivation.

In this document:
  - Options for the input attrset are prefixed by `mkShell.<in>`.
  - The returned attrset contans attributes prefixed by `mkShell.<out>`.


---

<h2>`mkShell.<in>.env`</h2> :: lazy attribute set of raw value


```nix
# Default:
{ }
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.name`</h2> :: string


```nix
# Default:
"nix-shell"
```
    
This field will be used as the shell's derivation name and it will also be used to fill in the default values for #TODO`prompt` and #TODO`welcomeMessage` below.


---

<h2>`mkShell.<in>.packages`</h2> :: list of package


```nix
# Default:
[ ]
```
    
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

If you `cabalProject` is in scope, you could use `hsPkgs` to obtain some useful binaries:
```nix
packages = [
  cabalProject.hsPkgs.cardano-cli.components.exes.cardano-cli
  cabalProject.hsPkgs.cardano-node.components.exes.cardano-node
];
```

Be careful not to reference your project's own cabal packages via `hsPkgs`. 

If you do, then `nix develop` will build your project every time you enter the shell, and it will fail to do so if there are Haskell compiler errors.


---

<h2>`mkShell.<in>.preCommit`</h2> :: submodule


```nix
# Default:
{ }
```
    
```nix
# Example:
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

It is sufficient to set the #TODO`enable` flag to `true` to make the hook active.

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

<h2>`mkShell.<in>.preCommit.cabal-fmt`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `cabal-fmt` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.cabal-fmt.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.cabal-fmt.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.cabal-fmt.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.editorconfig-checker`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `editorconfig-checker` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.editorconfig-checker.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.editorconfig-checker.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.editorconfig-checker.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.fourmolu`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `fourmolu` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.fourmolu.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.fourmolu.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.fourmolu.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.hlint`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `hlint` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.hlint.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.hlint.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.hlint.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.nixpkgs-fmt`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `nixpkgs-fmt` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.nixpkgs-fmt.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.nixpkgs-fmt.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.nixpkgs-fmt.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.optipng`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `optipng` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.optipng.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.optipng.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.optipng.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.prettier`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `prettier` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.prettier.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.prettier.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.prettier.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.purs-tidy`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `purs-tidy` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.purs-tidy.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.purs-tidy.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.purs-tidy.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.shellcheck`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `shellcheck` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.shellcheck.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.shellcheck.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.shellcheck.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.stylish-haskell`</h2> :: submodule


```nix
# Default:
{
  enable = false;
  extraOptions = "";
}
```
    
The `stylish-haskell` pre-commit hook.


---

<h2>`mkShell.<in>.preCommit.stylish-haskell.enable`</h2> :: boolean


```nix
# Default:
false
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.stylish-haskell.extraOptions`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.preCommit.stylish-haskell.package`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.prompt`</h2> :: null or string


```nix
# Default:
null
```
    
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

<h2>`mkShell.<in>.scripts`</h2> :: lazy attribute set of (submodule)


```nix
# Default:
{ }
```
    
```nix
# Example:
scripts = {

  foobar = {
    exec = \'\'
      # Bash code to be executed whenever the script `foobar` is run.
      echo "Delete me from your nix/shell.nix!"
    \'\';
    description = \'\'
      You might want to delete the foobar script.
    \'\';
    group = "bazwaz";
    enable = true;
  };

  waz.exec = \'\'
    echo "I don't have a group!"
  \'\';
};

```
Custom scripts for your shell.

`scripts` is an attrset where each attribute name is the script name each the attribute value is an attrset.

The attribute names (`foobar` and `waz` in the example above) will be available in your shell as commands under the same name.


---

<h2>`mkShell.<in>.scripts.<name>.description`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.scripts.<name>.enable`</h2> :: boolean


```nix
# Default:
true
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      exec = \'\'
        echo "I only run on Linux."
      \'\';
    };
  };
}

```
Whether to enable this string.

This can be used to include scripts conditionally.


---

<h2>`mkShell.<in>.scripts.<name>.exec`</h2> :: string


    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  scripts = {
    foo = {
      exec = \'\'
        echo "Hello, world!"
      \'\';
    };
  };
}

```
Bash code to be executed when the script is run.

This field is required.


---

<h2>`mkShell.<in>.scripts.<name>.group`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
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

<h2>`mkShell.<in>.shellHook`</h2> :: string


```nix
# Default:
""
```
    
```nix
# Example:
shellHook = \'\'
  # Bash code to be executed when you enter the shell.
  echo "I'm inside the shell!"
\'\';

```
Standard nix `shellHook`, to be executed every time you enter the shell.


---

<h2>`mkShell.<in>.tools`</h2> :: submodule


```nix
# Default:
{ }
```
    
Test


---

<h2>`mkShell.<in>.tools.cabal-fmt`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.cabal-fmt = repoRoot.nix.patched-cabal-fmt;
}

```
A package that provides the `cabal-fmt` executable.

If unset or `null`, a default `cabal-fmt` will be provided, which is independed of #TODOhaskellCompilerVersion.


---

<h2>`mkShell.<in>.tools.cabal-install`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.cabal-install = repoRoot.nix.patched-cabal-install;
}

```
A package that provides the `cabal-install` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.tools.editorconfig-checker`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.editorconfig-checker = repoRoot.nix.patched-editorconfig-checker;
}

```
A package that provides the `editorconfig-checker` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.fourmolu`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.fourmolu = repoRoot.nix.patched-fourmolu;
}

```
A package that provides the `fourmolu` executable.

If unset or `null`, a default `fourmolu` will be provided, which is independed of #TODOhaskellCompilerVersion.


---

<h2>`mkShell.<in>.tools.ghcid`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.ghcid = repoRoot.nix.patched-ghcid;
}

```
A package that provides the `ghcid` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.tools.haskell-language-server`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.haskell-language-server = repoRoot.nix.patched-haskell-language-server;
}

```
A package that provides the `haskell-language-server` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.tools.haskell-language-server-wrapper`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.haskell-language-server-wrapper = repoRoot.nix.pathced-haskell-language-server-wrapper;
}

```
A package that provides the `haskell-language-server-wrapper` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.tools.haskellCompiler`</h2> :: null or one of "ghc8107", "ghc928", "ghc964"


```nix
# Default:
"ghc8107"
```
    
```nix
# Example:
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
IOGX does this automatically when creating a shell with #TODOmkProject.mkShell.


---

<h2>`mkShell.<in>.tools.hlint`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.hlint = repoRoot.nix.patched-hlint;
}

```
A package that provides the `hlint` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.tools.nixpkgs-fmt`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.nixpkgs-fmt = repoRoot.nix.patched-nixpkgs-fmt;
}

```
A package that provides the `nixpkgs-fmt` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.optipng`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.optipng = repoRoot.nix.patched-optipng;
}

```
A package that provides the `optipng` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.prettier`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.prettier = repoRoot.nix.patched-prettier;
}

```
A package that provides the `prettier` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.purs-tidy`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.purs-tidy = repoRoot.nix.patched-purs-tidy;
}

```
A package that provides the `purs-tidy` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.shellcheck`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.shellcheck = repoRoot.nix.patched-shellcheck;
}

```
A package that provides the `shellcheck` executable.

If unset or `null`, the most recent version available will be used.


---

<h2>`mkShell.<in>.tools.stylish-haskell`</h2> :: null or package


```nix
# Default:
null
```
    
```nix
# Example:
# shell.nix 
{ repoRoot, inputs, pkgs, lib, system }:
lib.iogx.mkShell {
  tools.stylish-haskell = repoRoot.nix.patched-stylish-haskell;
}

```
A package that provides the `stylish-haskell` executable.

If unset or `null`, #TODOhaskellCompilerVersion will be used to select a suitable derivation.


---

<h2>`mkShell.<in>.welcomeMessage`</h2> :: null or string


```nix
# Default:
null
```
    
When entering the shell, this welcome message will be printed.

The same caveat about escaping back slashes in #TODO`prompt` applies here.

This field is optional and defaults to a simple welcome message using the #TODO`name` field.


---

<h2>`mkShell.<out>.devShell`</h2> :: package


    
```nix
# Example:
{ repoRoot, inputs, pkgs, lib, system }:
[
  {
    devShells.foo = (lib.iogx.mkShell {}).devShell;
  }
]

```
The actual shell derivation.
You can put this in your flake outputs.


---

<h2>`mkShell.<out>.pre-commit-check`</h2> :: package


    
```nix
# Example:
{ repoRoot, inputs, pkgs, lib, system }:
let
  shell = lib.iogx.mkShell {};
in 
[
  {
    devShells.foo = shell.devShell;
    packages.pre-commit-check = shell.pre-commit-check;
    hydraJobs.pre-commit-check = shell.pre-commit-check;
  }
]

```
A derivation that when built will run all the installed shell hooks.
The hooks are configured in #TODO preCommit
This derivation can be included in your packages and in hydraJobs.
Test


