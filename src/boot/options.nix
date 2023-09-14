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
        description = ''
          Enable the pre-commit hook.
          If false, the hook will not be installed.
          If true, the hook will become avaible in  
          pre-commit run <tool-name>
        '';
      };

      package = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          The package that provides the hook.
          The nixpkgs.lib.getExe function will be used to extract the program.
          If left null, the default package will be used.
        '';
      };

      extraOptions = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Each hooks knows how run itself
        '';
      };
    };
  };


  tools-submodule = l.types.submodule {
    options = {
      haskellCompiler = l.mkOption {
        type = l.types.nullOr l.types.str;
        # default = null; # TODO default?
        description = ''
          Test
        '';
      };

      cabal-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      cabal-install = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      haskell-language-server = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      haskell-language-server-wrapper = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      fourmolu = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      hlint = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      stylish-haskell = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      ghcid = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      shellcheck = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      prettier = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      editorconfig-checker = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      nixpkgs-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      png-optimization = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };

      purs-tidy = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          Test
        '';
      };
    };
  };


  pre-commit-submodule = l.types.submodule {
    options = {
      cabal-fmt = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      stylish-haskell = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      fourmolu = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      hlint = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      shellcheck = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      prettier = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      editorconfig-checker = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      nixpkgs-fmt = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      optipng = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };

      purs-tidy = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          Test
        '';
      };
    };
  };


  script-submodule = l.types.submodule {
    options = {
      exec = l.mkOption {
        type = l.types.str;
        description = ''
          Test
        '';
      };

      description = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Test
        '';
      };

      group = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Test
        '';
      };

      enable = l.mkOption {
        type = l.types.bool;
        default = true;
        description = ''
          Test
        '';
      };
    };
  };


  shell-submodule = l.types.submodule {
    options = {

      devShell = l.mkOption {
        type = l.types.package;
        readOnly = true;
        description = ''
          Test
        '';
      };

      preCommitCheck = l.mkOption {
        type = l.types.package;
        readOnly = true;
        description = ''
          Test
        '';
      };

      name = l.mkOption {
        type = l.types.str;
        default = "nix-shell";
        description = ''
          Test
        '';
      };

      prompt = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
        description = ''
          Test
        '';
      };

      welcomeMessage = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
        description = ''
          Test
        '';
      };

      packages = l.mkOption {
        type = l.types.listOf l.types.package;
        default = [ ];
        description = ''
          Test
        '';
      };

      scripts = l.mkOption {
        type = l.types.lazyAttrsOf script-submodule;
        default = { };
        description = ''
          Test
        '';
      };

      env = l.mkOption {
        type = l.types.lazyAttrsOf l.types.raw;
        default = { };
        description = ''
          Test
        '';
      };

      shellHook = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Test
        '';
      };

      tools = l.mkOption {
        type = tools-submodule;
        default = { };
        description = ''
          Test
        '';
      };

      preCommit = l.mkOption {
        type = pre-commit-submodule;
        default = { };
        description = ''
          Test
        '';
      };
    };
  };


  combined-haddock-submodule = l.types.submodule {
    options = {
      enable = l.mkOption {
        type = l.types.bool;
        default = false;
        description = ''
          Test 
        '';
      };

      packages = l.mkOption {
        type = l.types.listOf l.types.str;
        default = [ ];
        description = ''
          Test
        '';
      };

      prologue = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Test
        '';
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
        description = ''
          Test
        '';
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
        description = ''
          Test
        '';
      };

      shellFor = l.mkOption {
        type = l.types.functionTo shell-submodule;
        default = cabalProject: {
          tools.haskellCompiler = cabalProject.args.compiler-nix-name;
          name = cabalProject.args.name;
        };
        description = ''
          Test
        '';
      };

      combinedHaddock = l.mkOption {
        type = combined-haddock-submodule;
        default = default-combined-haddock;
        description = ''
          Test
        '';
      };

      readTheDocs = l.mkOption {
        type = read-the-docs-submodule;
        default = default-read-the-docs;
        description = ''
          Test
        '';
      };
    };
  };


  mkflake-submodule = l.types.submodule {
    options = {

      inputs = l.mkOption {
        type = l.types.raw;
        description = ''
          Test
        '';
      };

      repoRoot = l.mkOption {
        type = l.types.path;
        description = ''
          Test
        '';
      };

      systems = l.mkOption {
        type = l.types.listOf (l.types.enum [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ]);
        description = ''
          Test
        '';
      };

      outputs = l.mkOption {
        type = l.types.either l.types.path (l.types.functionTo l.types.raw);
        description = ''
          Test
        '';
      };

      flake = l.mkOption {
        type = l.types.attrs;
        default = { };
        description = ''
          Test
        '';
      };

      nixpkgsArgs = l.mkOption {
        type = l.types.attrs;
        default = { config = { }; overlays = [ ]; };
        description = ''
          Test
        '';
      };

      debug = l.mkOption {
        type = l.types.bool;
        default = false;
        description = ''
          Test
        '';
      };
    };
  };


  haskellProject = l.mkOption {
    type = haskell-project-submodule;
    description = ''
      Test
    '';
  };


  shell = l.mkOption {
    type = shell-submodule;
    description = ''
      Test
    '';
  };


  mkFlake = l.mkOption {
    type = mkflake-submodule;
    description = ''
      
      The attribute set 
    '';
  };
in

{ inherit haskellProject shell mkFlake; }



# default = pkgs.haskellPackages;
# defaultText = lib.literalExpression "pkgs.haskellPackages";
