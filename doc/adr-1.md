# Motivation

Nix is used in virtually all repositories at IOG to:
- Provision a comprehensive development environment (including CI)
- Deploy artifacts and manage cloud infrastructure 

IOGX (and this document) is presently only concerned with being a solution to the former.

The repositories that have integrated IOGX so far have benefitted from a 35%-85% reduction in lines of nix code.

We take that removing duplication to this degree is worth the effort, modulo the cost of maintaining IOGX.

With this in mind, we not only want to make the nix code "less", but also simpler and easier to maintain for non nix-savvy devs, to the point that the DevX team can become obsolete to an extent (i.e. developers are self-serving w.r.t. their devenv). 

The way we want to achieve this is by creating an Internal Developer Platform. Our Internal Developer Platform provides the comprehensive development environment in the form of the IOGX flake.

We hope that old and new repositories will use IOGX instead of copy-pasting thousands of lines of nix. 


# Current State 

What is common among all/most SC/IOG repos?

- The main language is Haskell with a cabal.project setup
- They use haskell.nix + CHaP
- They want a complete haskell toolchain (HLS, cabal, ghc, hlint, fourmolu, etc...)
- CI == hydraJobs 
- They want to build/test the project using multiple GHCs
- They want to do cross compilation on Windows 
- They want other formatters/hooks in the shell (shellcheck / png-optimization)
- They use read-the-docs for documentation 

All of the above are currently covered by IOGX out of the box.

In the future we want to support:

- Automatic haddock deployment to gh-pages
- Haskell benchmarking with alerts and history
- Test Coverage Reports
- Arbitrary Haskell project configurations 
- Some form of standard/automated way to create/deploy docker containers.

Currently IOGX exposes a single function called `mkFlake`, that takes some global config values, and then looks inside the `./nix` folder for specific files, imports those files, and uses those files to populate the flake outputs.

The files inside the nix folder must evaluate to attribute sets with specific schemas. 
This is a file-based, declarative interface.

While the "file-based" part might actually not add so much value (and in the proposal below is deprecated in favour of a fully attrset-based interface), the "declarative" part should probably be pursued, meaning: the user tells us what they want by defining attrsets of more-or-less simple data types, as opposed to by using a newly-crafted library of functions.

While the interface for the currently-supported feature-set is clean enough, there is room for improvement when it comes to non-common/unpredictable use cases coming from power users.

# Haskell Project Build Matrix

We want to support multiple GHCs, and this adds complexity to the interface and the implementation.

This is because for each GHC, we need a different HLS, which means a different hlint, stylish-haskell, etc. 

For each GHC, we might want to support profiling. And cross compiling (maybe to multiple targets). And static builds. And "selective" haddock compilation (see [here](https://github.com/input-output-hk/plutus-apps/blob/14ae5a40a147a4699c1cb7181ab471a40209c1eb/__std__/cells/plutus-apps/library/make-plutus-apps-project.nix#L5) -- btw, why?).

Ultimately we want to support arbitrary project configurations (e.g. building some components with specific GHC flags).

So what we have really is a matrix of haskell projects that we want expose in the interface, while maintaining a notion of a "default project". 

Even the `pre-commit-check` (which runs the formatters, including the haskell ones) becomes a matrix. Do we want to run `pre-commit-check` for each project in the matrix? For each GHC only? Just for the default project? Leave it to the user to decide? 

What about `read-the-docs`? 

This also means that we want a different `devShell` for each matrix element, or at least for each GHC + profiling?

And each haskell component (that ends up in `inputs.self.packages|apps`) needs to have a unique attribute name across the entire matrix.

This all extends to `hydraJobs`. 

We certainly want to hide this kind of complexity, and provide a way to make it easy for the user to configure and play with a matrix of projects, while making it trivial to select a default build matrix that fits most use-cases.

# New Interface
  
Below is what I think is a valid starting point.

```nix
# Template flake.nix
{
  description = "";


  inputs = {

    iogx = {
      url = "github:input-output-hk/iogx";
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
    # ^^^^^ CHaP and Hackage inputs are now made explicit by default.
    # Should we do the same for nixpkgs? haskell.nix?
  };


  outputs = inputs: inputs.iogx.lib.mkFlake {

    inherit inputs;
    
    repoRoot = ./.;

    systems = ["x86_64-linux" "x86_64-darwin"];
    
    nixpkgsArgs = {
      config = {};
      overlays = [];
    };
    # ^^^^^ Internally this is fed to `import inputs.nixpkgs {}`


    makeOutputs = { inputs, repoRoot }: {

      projectMatrix = {};

      makeProject = { matrix }: {};

      extraOutputs = {};
    };
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

## Description of `makeOutputs = { inputs, repoRoot }:`

The `makeOutputs` function would be called by IOGX once for each system in `systems`.

`inputs` is the de-systemized inputs, which is what you want 99.99% of the time.

You only want to use the original inputs when you need to access the flake source (e.g. `import inputs.haskell-nix {}`) but even in that case, the de-systemized version works just as well.

"de-systemizing" the inputs doesn't actually stop you from accessing per-system attributes. The following syntax is valid on any system:
```nix 
inputs.self.apps.foo 
# ^^^^^ Uses the current system

inputs.self.apps.x86_64-darwin.foo 
# ^^^^^ This attribute is present on linux too, but obv. may fail to evaluate

inputs.nixpkgs.hello
inputs.nixpkgs.x86_64-darwin.hello
```
Turns out that there is no need to have both (`inputs`/`inputs'` or `inputs`/`perSystemInputs`).

In the current version of IOGX we expose `pkgs`, `lib` and `system`.
But we can just as well do this now:
```nix 
pkgs = inputs.nixpkgs; 
# ^^^^^ Already de-systemized and actually set to inputs.nixpkgs.legacyPackages.$system 
# Internally it is overlaid with iogx-nix and haskell.nix and nixpkgsArgs from mkFlake

system = inputs.nixpkgs.stdenv.system; 
lib = pkgs.lib;
```

Now the idea for the `repoRoot` argument is taken straight from `std`.

`repoRoot` is to IOGX what `cell(s)` is to `std`, except that we don't have a concept of a hierarchy of `blocks` of `cells`, we just have `repoRoot` to get to any file in the repo (e.g. `repoRoot."cabal.project"` or more commonly with nix files `repoRoot.nix.folder.file`)

Note that the nix files that are wanted to be accessed by dot notation using `repoRoot` are expected to have this format: `{ inputs, repoRoot }: X` 

Or optionally just be `X` if neither `inputs` nor `repoRoot` are needed.

This is just like in `std`, where you expect nix files to be like `{ inputs, cell }: X`.

## Description of `extraOutputs`

```nix 
extraOutputs = {

  packages.foo = repoRoot.nix.some-nix-file;

  devShells.shell1 = {..}
  devShells.shell2 = {..};

  hydraJobs.nested.hello = inputs.self.packages.hello;

  non-standard-outputs = {..};

  oci-images.example = inputs.self.cabalProjects.ghc8107.example;
  nomadTasks = {..};
};
```

In here the user can put anything they want, they can add to the final outputs.

The `inputs` arguments has the `self` argument, which means that the user has access to **our** outputs as well.

In addition, it is guaranteed that they will want to reference the `haskell.nix:cabalProject'` project(s) directly.

Because we are in charge of making the project matrix, we will add `inputs.self.cabalProjects` to the flake outputs (with a `inputs.self.cabalProjects.default`).

Internally, we will recursively merge the `extraOutputs` attrset with the final flake outputs attrset produced by us, and print warnings/errors in case of name clashes.

## Description of `projectMatrix`

```nix 
projectMatrix = {

  ghc = ["ghc8107" "ghc928" "ghc962"];
  targetHost = ["mingwW64" "musl" "native"];
  enableProfiling = [ true false ];
  enableHaddock = [ true false ]; 
  # ^^^^^ builtins: we handle these

  customString = ["a" "b" "c"];
  customInt = [1 2]
  # ^^^^^ user-defined
}
```

The above provides a way to create an arbitrary matrix of Haskell projects.

Internally we generate the matrix and call `makeProject` for each element. 

The example above would yield a matrix of 216 elements/projects.

## Description of `makeProject`

```nix
makeProject = { matrix }: {

  projectTag = "";

  isDefaultProject = false;

  addFlakeOutputs = true; 

  addHydraJobs = true;

  tools = {
    cabalInstall = "default";
    haskellLanguageServer = some-drv;
    fourmolu = if matrix.ghc == "ghc8107" then "default" else some-drv;
    # hlint
    # stylish-haskell
    # ghcid
  };

  defaultChangelogPackages = [];

  combinedHaddock = { 
    enable = false; 
    projectPackages = [];
    prologue = "";
  };

  readTheDocsFolder = null; 


  cabalProjectArgs = { config }: { 
    cabalProjectLocal = "";
    sha256map = {};
    shell = {}
    modules = {};
    overlays = [];
  };

  shellFor = { project }: {
    
    prompt = "";
    welcomeMessage = "";
    packages = [];
    scripts = {};
    env = {};
    enterShell = "";

    preCommitHooks = {
      nixpkgs-fmt.enable = true;
      nixpkgs-fmt.extraOptions = "";
      # nixpkgs-fmt.package = "default";

      hlint.enable = true;
      hlint.extraOptions = "";
      # We don't offer hlint.package because this is set in `tools` above.

      # cabal-fmt
      # stylish-haskell 
      # png-optimization 
      # shellcheck
    };
  };
}
```

This function is called for each row in the `projectMatrix`.

### The `projectTag` field

Suppose you have two `ghc`s (`ghc8107` and `ghc928`) and we want to enable profiling. 
We need a way to name each project and each output. 
We might want to end up with:
```nix 
inputs.self.cabalProjects.ghc8107
inputs.self.cabalProjects.ghc8107-profiled
inputs.self.cabalProjects.ghc928
inputs.self.cabalProjects.ghc928-profiled

nix build .#package-exe-foo-ghc8107
nix build .#package-exe-foo-ghc8107-profiled
nix build .#package-exe-foo-ghc928
nix build .#package-exe-foo-ghc928-profiled

nix develop .#ghc8107
nix develop .#ghc8107-profiled
nix develop .#ghc928
nix develop .#ghc928-profiled
```

With a more complex `projectMatrix` we want to let the user make the tag.

Still the `projectTag` field can be omitted and we will generate a unique tag across the matrix. 

A warning will be generated if the same project tag is produced from different `matrix` args.

### The `isDefaultProject` field

We need a concept of a `defaultProject` which is the one that will be selected when running `nix develop` and which will end up in `inputs.self.cabalProjects.default`.

By default we can make the default project the one with the left-most GHC in `projectMatrix.ghc` (or add a `defaultGhc` to `mkFlake`), no profiling, no haddock, no custom user flags.

A warning will be generated if more than one `matrix` yield a default project.

### The `addFlakeOutputs` field 

We might want to make a project but not include the actual flake outputs. 

This means that the project will end up in `inputs.self.cabalProjects` but not in `inputs.self.packages|apps|checks|devShells`. 

If this field is omitted then we just make outputs for the default project.

### The `tools` field 

Haskell-specific tools.

If the `cabalInstall` field is omitted or set to `"default"` then we will select the right one w.r.t. `matrix.ghc`.

Same for `haskellLanguageServer`.

And same for `fourmolu`, `hlint`, `stylish-haskell` and `ghcid`: if set to `"default"` or omitted, we extract them from `haskellLanguageServer`.

The entire `tools` field can be omitted and it will default to the latest version for each tool.

### The `defaultChangelogPackages` field

Field for the scriv changelog scripts. 

### The `combinedHaddock` field 

Fields for making the combined haddock. 

### The `readTheDocsFolder` field

This should probably be moved to `mkFlake` top-level and created only for the default project.

### The `addHydraJobs` field 

Similar to `addFlakeOutputs`, this field decides whether exes, libs and test-suites end up in Hydra for this project. Same default value as `addFlakeOutputs`.
More control can be obtained in `extraOutputs` by working with `inputs.self.cabalProjects` directly.

### The `cabalProjectArgs` field

Stuff that gets passed almost directly to `haskell.nix:cabalProject'`

### The `shellFor` field

For each project we need a shell.

At this stage the project has been created and so can be passed to `shellFor`.

Each shell will be added to the flake outputs as `devShells.$TAG`. Where `$TAG` is the `projectTag` obtained in `makeProject`.

This feels like a good place to place the `pre-commit-hooks` too (formerly `./nix/formatters.nix`)

