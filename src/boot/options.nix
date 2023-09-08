iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;


  default-pre-commit-hook = {
    enable = false;
    extraOptions = "";
  };


  pre-commit-hook-submodule = l.types.submodule {
    options = {
      enable = l.mkOption {
        type = l.types.bool;
        default = false;
      };

      extraOptions = l.mkOption {
        type = l.types.str;
        default = "";
      };
    };
  };


  tools-submodule = l.types.submodule {
    options = {
      haskellCompiler = l.mkOption {
        type = l.types.nullOr l.types.str;
        # default = null; # TODO default?
      };

      cabal-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      cabal-install = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      haskell-language-server = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      haskell-language-server-wrapper = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      fourmolu = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      hlint = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      stylish-haskell = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      ghcid = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      shellcheck = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      prettier = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      editorconfig-checker = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      nixpkgs-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      png-optimization = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };

      purs-tidy = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
      };
    };
  };


  pre-commit-submodule = l.types.submodule {
    options = {
      cabal-fmt = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      stylish-haskell = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      fourmolu = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      hlint = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      shellcheck = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      prettier = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      editorconfig-checker = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      nixpkgs-fmt = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      optipng = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };

      purs-tidy = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
      };
    };
  };


  script-submodule = l.types.submodule {
    options = {
      exec = l.mkOption {
        type = l.types.str;
      };

      description = l.mkOption {
        type = l.types.str;
        default = "";
      };

      group = l.mkOption {
        type = l.types.str;
        default = "";
      };

      enable = l.mkOption {
        type = l.types.bool;
        default = true;
      };
    };
  };


  shell-submodule = l.types.submodule {
    options = {

      devShell = l.mkOption {
        type = l.types.package;
        readOnly = true;
      };

      preCommitCheck = l.mkOption {
        type = l.types.package;
        readOnly = true;
      };

      name = l.mkOption {
        type = l.types.str;
        default = "nix-shell";
      };

      prompt = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
      };

      welcomeMessage = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
      };

      packages = l.mkOption {
        type = l.types.listOf l.types.package;
        default = [ ];
      };

      scripts = l.mkOption {
        type = l.types.lazyAttrsOf script-submodule;
        default = { };
      };

      env = l.mkOption {
        type = l.types.lazyAttrsOf l.types.raw;
        default = { };
      };

      shellHook = l.mkOption {
        type = l.types.str;
        default = "";
      };

      tools = l.mkOption {
        type = tools-submodule;
        default = { };
      };

      preCommit = l.mkOption {
        type = pre-commit-submodule;
        default = { };
      };
    };
  };


  combined-haddock-submodule = l.types.submodule {
    options = {
      enable = l.mkEnableOption "combined-haddock";

      packages = l.mkOption {
        type = l.types.listOf l.types.str;
        default = [ ];
      };

      prologue = l.mkOption {
        type = l.types.str;
        default = "";
      };
    };
  };


  default-combined-haddock = {
    enable = false;
    packages = [ ];
    prologue = "";
  };


  read-the-docs-submodule = l.types.submodule {
    options = {
      siteFolder = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
      };
    };
  };


  default-read-the-docs = {
    siteFolder = null;
  };


  haskell-project-submodule = l.types.submodule {

    options = {

      cabalProjectArgs = l.mkOption {
        type = l.types.raw;
        default = { };
      };

      shellFor = l.mkOption {
        type = l.types.functionTo shell-submodule;
        default = cabalProject: {
          tools.haskellCompiler = cabalProject.args.compiler-nix-name;
          name = cabalProject.args.name;
        };
      };

      combinedHaddock = l.mkOption {
        type = combined-haddock-submodule;
        default = default-combined-haddock;
      };

      readTheDocs = l.mkOption {
        type = read-the-docs-submodule;
        default = default-read-the-docs;
      };
    };
  };


  haskellProject = l.mkOption {
    type = haskell-project-submodule;
  };


  shell = l.mkOption {
    type = shell-submodule;
  };

in

{ inherit haskellProject shell; }


# cabalProjects.<name>.outputs.project.native = null; # haskell.nix:project
# cabalProjects.<name>.outputs.project.profiled = null;
# cabalProjects.<name>.outputs.project.mingwW64 = null;
# cabalProjects.<name>.outputs.project.musl64 = null;
# cabalProjects.<name>.outputs.combinedHaddock = derivation;
# cabalProjects.<name>.outputs.readTheDocsSite = derivation;
# cabalProjects.<name>.project = pkgs.haskell-nix.cabalProjects' {};
# cabalProjects.<name>.combinedHaddock.projectPackages = [ ];
# cabalProjects.<name>.combinedHaddock.prologue = "";
# cabalProjects.<name>.readTheDocs.rootFolder = path;
# cabalProjects.<name>.shell = shell-submodule;

# # cabalProjects.<name>.populatePackagesChecksAppsDevShells = bool;
# # cabalProjects.<name>.populateHydraJobs = bool;
# # cabalProjects.<name>.addReadTheDocsSiteToOutputs = bool;
# # cabalProjects.<name>.addCombinedHaddockToOutputs = bool;
# # cabalProjects.<name>.flake.apps.* = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.checks.* = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.packages.* = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.devShells.<name> = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.hydraJobs.checks.* = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.hydraJobs.packages.* = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.hydraJobs.devShells.<name> = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.hydraJobs.roots = derivation; # *** OUTPUT ***
# # cabalProjects.<name>.flake.hydraJobs.plan-nix = derivation; # *** OUTPUT ***

# shells.<name>.outputs.devShell = derivation; # *** OUTPUT ***
# shells.<name>.outputs.preCommitCheck = derivation; # *** OUTPUT ***

# # shells.<name>.addDevShellToOutputs = derivation; # *** OUTPUT ***
# # shells.<name>.addPreCommitCheckToOutputs = derivation; # *** OUTPUT ***
# # shells.<name>.addPreCommitCheckToHydraJobs = derivation; # *** OUTPUT ***

# shells.<name>.name = str; 
# shells.<name>.prompt = str;
# shells.<name>.welcomeMessage = str;
# shells.<name>.packages = list;
# shells.<name>.scripts = attrs;
# shells.<name>.env = attrs;
# shells.<name>.shellHook = str;

# shells.<name>.tools.haskellCompiler = str; 

# shells.<name>.tools.cabal-install = derviation; # *** OUTPUT ***
# shells.<name>.tools.haskell-language-server-project = derviation; # *** OUTPUT ***
# shells.<name>.tools.ghcid = derviation; # *** OUTPUT ***

# shells.<name>.preCommit.nixpkgs-fmt.enable = bool;
# shells.<name>.preCommit.nixpkgs-fmt.extraOptions = str;
# shells.<name>.preCommit.nixpkgs-fmt.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.png-optimization.enable = bool;
# shells.<name>.preCommit.png-optimization.extraOptions = str;
# shells.<name>.preCommit.png-optimization.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.shellcheck.enable = bool;
# shells.<name>.preCommit.shellcheck.extraOptions = str;
# shells.<name>.preCommit.shellcheck.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.purs-tidy.enable = bool;
# shells.<name>.preCommit.purs-tidy.extraOptions = str;
# shells.<name>.preCommit.purs-tidy.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.hlint.enable = bool;
# shells.<name>.preCommit.hlint.extraOptions = str;
# shells.<name>.preCommit.hlint.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.cabal-fmt.enable = bool;
# shells.<name>.preCommit.cabal-fmt.extraOptions = str;
# shells.<name>.preCommit.cabal-fmt.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.stylish-haskell.enable = bool;
# shells.<name>.preCommit.stylish-haskell.extraOptions = str;
# shells.<name>.preCommit.stylish-haskell.package = derivation; # *** OUTPUT ***

# shells.<name>.preCommit.fourmolu.enable = bool;
# shells.<name>.preCommit.fourmolu.extraOptions = str;
# shells.<name>.preCommit.fourmolu.package = derivation; # *** OUTPUT ***
