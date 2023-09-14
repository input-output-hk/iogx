# IOGX 

### `mkFlake`

#### Type: `core API function`



#### Example: 
```nix
# ./flake.nix
outputs = inputs: inputs.iogx.lib.mkFlake {
  inherit inputs;
  repoRoot = ./.;
  systems = [ "x86_64-linux" "x86_64-darwin" ];
  outputs = { repoRoot, inputs, pkgs, lib, system }: [];
};

```


#### Description:

The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

In this document:
  - Options for the input attrset are prefixed by `mkFlake.<in>`.
  - The returned attrset contans attributes prefixed by `mkFlake.<out>`.


### `mkFlake.<in>.debug`

#### Type: `boolean`

#### Default: `false`




#### Description:

If enabled, IOGX will trace debugging info to standard output.


### `mkFlake.<in>.flake`

#### Type: `attribute set`

#### Default: `{ }`


#### Example: 
```nix
{
  lib = { 
    bar = _: null;
  };
  packages.x86_64-linux.foo = null;
  devShells.x86_64-darwin.bar = null;
}

```


#### Description:

A flake-like attrset.

You can place additional flake outputs here, which will be recursively updated with the outputs from #TODOmkFlake.outputs.

This is a good place to put system-independent values like a `lib` attrset or JSON-like config data.


### `mkFlake.<in>.inputs`

#### Type: `attribute set`





#### Description:

Your flake inputs.
You want to do `inherit inputs;` here.


### `mkFlake.<in>.nixpkgsArgs`

#### Type: `attribute set`

#### Default: 
```nix
{ 
  config = { }; 
  overlays = [ ]; 
}

```




#### Description:

Internally, IOGX calls `import inputs.nixpkgs {}`.

Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.


### `mkFlake.<in>.outputs`

#### Type: `function that evaluates to a(n) list of (attribute set)`



#### Example: 
```nix
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


#### Description:

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


### `mkFlake.<in>.repoRoot`

#### Type: `path`

#### Default: `null`


#### Example: `/nix/store/3hh9v3hkvjaaqzpn5qd2921df6nxck40-source/src/boot`


#### Description:

The root of your repository.
If not set, this will default to the folder containing the flake.nix file, using `inputs.self`.


### `mkFlake.<in>.systems`

#### Type: `list of (one of "x86_64-linux", "x86_64-darwin", "aarch64-darwin", "aarch64-linux")`

#### Default: `[ "x86_64-linux" "x86_64-darwin" ]`




#### Description:

The systems you want to build for.
Available systems are `x86_64-linux`, `x86_64-darwin`, `aarch64-darwin`, `aarch64-linux`.


### `mkFlake.<out>."<flake>"`

#### Type: `attribute set`

#### Default: `{ }`




#### Description:

Test

### `mkProject`

#### Type: `core API function`





#### Description:

asd

### `mkProject.<in>.cabalProjectArgs`

#### Type: `raw value`

#### Default: `{ }`




#### Description:

Test


### `mkProject.<in>.combinedHaddock`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  packages = [ ];
  prologue = "";
}
```




#### Description:

Test


### `mkProject.<in>.combinedHaddock.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Test 


### `mkProject.<in>.combinedHaddock.packages`

#### Type: `list of string`

#### Default: `[ ]`




#### Description:

Test


### `mkProject.<in>.combinedHaddock.prologue`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkProject.<in>.mkShell`

#### Type: `function that evaluates to a(n) (submodule)`

#### Default: `<function>`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.env`

#### Type: `lazy attribute set of raw value`

#### Default: `{ }`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.name`

#### Type: `string`

#### Default: `"nix-shell"`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.packages`

#### Type: `list of package`

#### Default: `[ ]`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit`

#### Type: `submodule`

#### Default: `{ }`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.cabal-fmt`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.cabal-fmt.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.cabal-fmt.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.cabal-fmt.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.editorconfig-checker`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.editorconfig-checker.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.editorconfig-checker.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.editorconfig-checker.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.fourmolu`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.fourmolu.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.fourmolu.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.fourmolu.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.hlint`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.hlint.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.hlint.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.hlint.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.nixpkgs-fmt`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.nixpkgs-fmt.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.nixpkgs-fmt.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.nixpkgs-fmt.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.optipng`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.optipng.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.optipng.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.optipng.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.prettier`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.prettier.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.prettier.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.prettier.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.purs-tidy`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.purs-tidy.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.purs-tidy.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.purs-tidy.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.shellcheck`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.shellcheck.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.shellcheck.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.shellcheck.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.preCommit.stylish-haskell`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.preCommit.stylish-haskell.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkProject.<in>.mkShell.<function body>.preCommit.stylish-haskell.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkProject.<in>.mkShell.<function body>.preCommit.stylish-haskell.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkProject.<in>.mkShell.<function body>.prompt`

#### Type: `null or string`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.scripts`

#### Type: `lazy attribute set of (submodule)`

#### Default: `{ }`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.scripts.<name>.description`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.scripts.<name>.enable`

#### Type: `boolean`

#### Default: `true`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.scripts.<name>.exec`

#### Type: `string`





#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.scripts.<name>.group`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.shellHook`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools`

#### Type: `submodule`

#### Default: `{ }`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.cabal-fmt`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.cabal-install`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.editorconfig-checker`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.fourmolu`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.ghcid`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.haskell-language-server`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.haskell-language-server-wrapper`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.haskellCompiler`

#### Type: `null or string`





#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.hlint`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.nixpkgs-fmt`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.png-optimization`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.prettier`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.purs-tidy`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.shellcheck`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.tools.stylish-haskell`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.mkShell.<function body>.welcomeMessage`

#### Type: `null or string`

#### Default: `null`




#### Description:

Test


### `mkProject.<in>.readTheDocs`

#### Type: `submodule`

#### Default: 
```nix
{
  siteFolder = null;
}
```




#### Description:

Test


### `mkProject.<in>.readTheDocs.siteFolder`

#### Type: `null or string`

#### Default: `null`




#### Description:

Test


### `mkProject.<out>.apps`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.checks`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.defaultFlakeOutputs`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.devShell`

#### Type: `package`





#### Description:

Test


### `mkProject.<out>.flake`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.hydraJobs`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.packages`

#### Type: `attribute set`





#### Description:

Test


### `mkProject.<out>.pre-commit-check`

#### Type: `package`





#### Description:

Test


### `mkProject.<out>.read-the-docs-site`

#### Type: `package`





#### Description:

Test


### `mkShell`

#### Type: `core API function`





#### Description:

asd

### `mkShell.<in>.env`

#### Type: `lazy attribute set of raw value`

#### Default: `{ }`




#### Description:

Test


### `mkShell.<in>.name`

#### Type: `string`

#### Default: `"nix-shell"`




#### Description:

Test


### `mkShell.<in>.packages`

#### Type: `list of package`

#### Default: `[ ]`




#### Description:

Test


### `mkShell.<in>.preCommit`

#### Type: `submodule`

#### Default: `{ }`




#### Description:

Test


### `mkShell.<in>.preCommit.cabal-fmt`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.cabal-fmt.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.cabal-fmt.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.cabal-fmt.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.editorconfig-checker`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.editorconfig-checker.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.editorconfig-checker.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.editorconfig-checker.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.fourmolu`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.fourmolu.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.fourmolu.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.fourmolu.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.hlint`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.hlint.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.hlint.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.hlint.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.nixpkgs-fmt`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.nixpkgs-fmt.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.nixpkgs-fmt.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.nixpkgs-fmt.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.optipng`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.optipng.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.optipng.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.optipng.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.prettier`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.prettier.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.prettier.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.prettier.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.purs-tidy`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.purs-tidy.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.purs-tidy.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.purs-tidy.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.shellcheck`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.shellcheck.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.shellcheck.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.shellcheck.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.preCommit.stylish-haskell`

#### Type: `submodule`

#### Default: 
```nix
{
  enable = false;
  extraOptions = "";
}
```




#### Description:

Test


### `mkShell.<in>.preCommit.stylish-haskell.enable`

#### Type: `boolean`

#### Default: `false`




#### Description:

Enable the pre-commit hook.
If false, the hook will not be installed.
If true, the hook will become avaible in  
pre-commit run <tool-name>


### `mkShell.<in>.preCommit.stylish-haskell.extraOptions`

#### Type: `string`

#### Default: `""`




#### Description:

Each hooks knows how run itself


### `mkShell.<in>.preCommit.stylish-haskell.package`

#### Type: `null or package`

#### Default: `null`




#### Description:

The package that provides the hook.
The nixpkgs.lib.getExe function will be used to extract the program.
If left null, the default package will be used.


### `mkShell.<in>.prompt`

#### Type: `null or string`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.scripts`

#### Type: `lazy attribute set of (submodule)`

#### Default: `{ }`




#### Description:

Test


### `mkShell.<in>.scripts.<name>.description`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkShell.<in>.scripts.<name>.enable`

#### Type: `boolean`

#### Default: `true`




#### Description:

Test


### `mkShell.<in>.scripts.<name>.exec`

#### Type: `string`





#### Description:

Test


### `mkShell.<in>.scripts.<name>.group`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkShell.<in>.shellHook`

#### Type: `string`

#### Default: `""`




#### Description:

Test


### `mkShell.<in>.tools`

#### Type: `submodule`

#### Default: `{ }`




#### Description:

Test


### `mkShell.<in>.tools.cabal-fmt`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.cabal-install`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.editorconfig-checker`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.fourmolu`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.ghcid`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.haskell-language-server`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.haskell-language-server-wrapper`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.haskellCompiler`

#### Type: `null or string`





#### Description:

Test


### `mkShell.<in>.tools.hlint`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.nixpkgs-fmt`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.png-optimization`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.prettier`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.purs-tidy`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.shellcheck`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.tools.stylish-haskell`

#### Type: `null or package`

#### Default: `null`




#### Description:

Test


### `mkShell.<in>.welcomeMessage`

#### Type: `null or string`

#### Default: `null`




#### Description:

Test


### `mkShell.<out>.devShell`

#### Type: `package`





#### Description:

Test


### `mkShell.<out>.pre-commit-check`

#### Type: `package`





#### Description:

Test


