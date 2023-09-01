# Modular Interface

```nix 
# The new template flake.nix
{
  inputs = # Nothing new 


  outputs = inputs: inputs.iogx.lib.mkFlake {

    inherit inputs;

    systems = ["x86_64-linux" "x86_64-darwin"];

    modules = [
      ({ inputs, root, ... }: { packages = ..; devShells = ..; hydraJobs = ..; })
      ({ inputs, root, ... }: { packages = ..; devShells = ..; })
      ({ inputs, root, ... }: { devShells = ..; })
      ({ inputs, root, ... }: { operables = ..; oci-images = ..; })
      ({ inputs, root, ... }: { nomadTasks = ..; })
      ...
    ];
    # ^^^^^ Just like the modules in haskell.nix
    # Each module is a function to a flake (packages, hydraJobs, devShells, oci-images, ...) 
    # Each module is recursively merged top-to-bottom and a warning is raised on name clash
  };


  nixConfig = # Nothing new 
}
``` 

Even if this were not a haskell project, we get:
- `root` for attrset-based access to files and folders
- A way to recursively merge flake outputs and get warnings on name clash 

Now we can put functions inside `inputs.iogx.lib` to make & play with modules.

# `inputs.iogx.lib.makeCabalProjectsModule`

```nix 
inputs.iogx.lib.makeCabalProjectsModule {

  buildMatrix = {
    ghc = ["ghc8107" "ghc928" "ghc962"];
    targetHost = ["mingwW64" "musl" "native"];
    enableProfiling = [ true false ];
    enableHaddock = [ true false ]; 
    # ^^^^^ builtins
    customString = ["a" "b" "c"];
    customInt = [1 2];
    # ^^^^^ user-defined
  };

  makeProject = config@{ ghc, targetHost, ..., customString, ... }: 
    # ^^^^ Called for each row in buildMatrix

    id = "default"; # Must be unique across the matrix

    cabalProjectFile = ./cabal.project; 

    defaultChangelogPackages = [];
  
    readTheDocsFolder = null; 

    combinedHaddock = { 
      enable = false; 
      projectPackages = [];
      prologue = "";
    };

    tools = {
      cabalInstall = "default" or derviation;
      haskellLanguageServer = "default" or derviation;
      fourmolu = "default" or derviation;
      hlint = "default" or derviation;
      stylish-haskell = "default" or derviation;
      ghcid = "default" or derviation;
    };

    haskellDotNixCabalProject = iogx.lib.makeHaskellDotNixCabalProject {
      # ^^^^^ where makeHaskellDotNixCabalProject is just a thin wrapper around haskell.nix:cabalProject'
      cabalProjectLocal = "";
      sha256map = {};
      shell = {}
      modules = {};
      overlays = [];
    }; # ... Or you can call haskell.nix:cabalProject' yourself

    shell = { cabalProject }: { # The shell receives the made haskell.nix:cabalProject
      # ^^^^^ And it produces an augmented devShell with preCommitHooks

      prompt = "";
      welcomeMessage = "";
      packages = [];
      scripts = {};
      env = {};
      shellHook = "";

      preCommitHooks = {
        nixpkgs-fmt.enable = true;
        nixpkgs-fmt.extraOptions = "";
        hlint.enable = true;
        hlint.extraOptions = "";
        # cabal-fmt, stylish-haskell, png-optimization, shellcheck, ...
      };
    };
};
```

The function above produces an attrset, where each attribute name is the `id` from `makeProject` and its value is an augmented cabal project as defined below:

```nix
cabalProject = # return value of haskell.nix:cabalProject'

# haskell.nix:cabalProject' already contains the `flake` attr, but we augment it:
cabalProject.flake.devShells.default = # the augmented shell 
cabalProject.flake.hydraJobs.devShells.default = # the augmented shell 

iogx = {
  config = # same as the config passed to makeProject
  tools = # computed derivations for the tools
  id = # same as the id passed to makeProject 
  read-the-docs-site = # derivation for the read-the-docs-site (optional)
  pre-commit-check = # derivation for the pre-commit-check 
}

augmentedCabalProject = cabalProject // { inherit iogx; }
```

The final attrset is named `cabalProjects` (notice the `s`) and is added to the flake outputs.

This means that it can be consumed by other modules: 

```nix 
# flake.nix
{
  ...
  outputs = inputs: inputs.iogx.lib.mkFlake {
    ... 
    modules = [
      ./nix/producer.nix
      ./nix/consumer.nix
    ];
  };
}

# ./nix/producer.nix
{ inputs, ... }:
inputs.iogx.lib.makeCabalProjectsModule {}

# ./nix/consumer.nix 
{ inputs, lib, ... }: 
let 
  projects = inputs.self.cabalProjects;
in 
{
  packages = inputs.iogx.lib.recursiveUpdateManyWithWarning [
    projects.ghc8107.flake.packages
    projects.ghc927.flake.packages
    projects.ghc927-profiled.flake.packages
  ];

  checks = inputs.iogx.lib.recursiveUpdateManyWithWarning [
    projects.ghc8107.checks.packages
    projects.ghc927.checks.packages
    projects.ghc927-profiled.checks.packages
  ];

  devShells.default = devShells.ghc8017; 
  devShells.ghc8017 = projects.ghc8107.flake.devShells.default;
  devShells.ghc8107-profiled = projects.ghc8107-profiled.flake.devShells.default;

  hydraJobs.ghc8017 = projects.ghc8107.flake.hydraJobs;
  hydraJobs.ghc927-profiled = projects.ghc927-profiled.flake.hydraJobs;

  hydraJobs.packages.read-the-docs-site = projects.default.iogx.read-the-docs-site;
  hydraJobs.packages.pre-commit-check = projects.default.iogx.pre-commit-check;
}
``` 
