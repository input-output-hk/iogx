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


  mkFlake-IN-submodule = l.types.submodule {
    options = {

      inputs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Your flake inputs.
          You want to do `inherit inputs;` here.
        '';
      };

      repoRoot = l.mkOption {
        type = l.types.path;
        description = ''
          The root of your repository.
          If not set, this will default to the folder containing the flake.nix file, using `inputs.self`.
        '';
        default = null;
        example = ./.;
      };

      systems = l.mkOption {
        type = l.types.listOf (l.types.enum [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ]);
        description = ''
          The systems you want to build for.
          Available systems are `x86_64-linux`, `x86_64-darwin`, `aarch64-darwin`, `aarch64-linux`.
        '';
        default = [ "x86_64-linux" "x86_64-darwin" ];
        defaultText = l.literalExpression ''[ "x86_64-linux" "x86_64-darwin" ]'';
      };

      outputs = l.mkOption {
        type = l.types.functionTo (l.types.listOf l.types.attrs);
        example = l.literalExpression ''
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
        '';
        description = ''
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
        '';
      };

      flake = l.mkOption {
        type = l.types.attrs;
        default = { };
        description = ''
          A flake-like attrset.

          You can place additional flake outputs here, which will be recursively updated with the outputs from #TODOmkFlake.outputs.

          This is a good place to put system-independent values like a `lib` attrset or JSON-like config data.
        '';
        example = l.literalExpression ''
          {
            lib = { 
              bar = _: null;
            };
            packages.x86_64-linux.foo = null;
            devShells.x86_64-darwin.bar = null;
          }
        '';
      };

      # TODO missing config/overlays in implementation
      nixpkgsArgs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Internally, IOGX calls `import inputs.nixpkgs {}`.

          Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.
        '';
        default = {
          config = { };
          overlays = [ ];
        };
        defaultText = l.literalExpression ''
          { 
            config = { }; 
            overlays = [ ]; 
          }
        '';
      };

      debug = l.mkOption {
        type = l.types.bool;
        default = false;
        description = ''
          If enabled, IOGX will trace debugging info to standard output.
        '';
      };
    };
  };


  mkProject-IN-submodule = l.types.submodule {
    options = {

      cabalProjectArgs = l.mkOption {
        type = l.types.raw;
        default = { };
        description = ''
          Test
        '';
      };

      mkShell = l.mkOption {
        type = l.types.functionTo mkShell-IN-submodule;
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


  mkShell-IN-submodule = l.types.submodule {
    options = {

      # devShell = l.mkOption {
      #   type = l.types.package;
      #   readOnly = true;
      #   description = ''
      #     Test
      #   '';
      # };

      # preCommitCheck = l.mkOption {
      #   type = l.types.package;
      #   readOnly = true;
      #   description = ''
      #     Test
      #   '';
      # };

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


  mkFlake-OUT-submodule = l.types.submodule {
    options."<flake>" = l.mkOption {
      type = l.types.attrs;
      default = { };
      description = "Test";
    };
  };

  mkProject-OUT-submodule = l.types.submodule {
    options = {

      defaultFlakeOutputs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      flake = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      packages = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      apps = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      checks = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      hydraJobs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Test
        '';
      };

      devShell = l.mkOption {
        type = l.types.package;
        description = ''
          Test
        '';
      };

      read-the-docs-site = l.mkOption {
        type = l.types.package;
        description = ''
          Test
        '';
      };

      pre-commit-check = l.mkOption {
        type = l.types.package;
        description = ''
          Test
        '';
      };
    };
  };


  mkShell-OUT-submodule = l.types.submodule {
    options = {

      devShell = l.mkOption {
        type = l.types.package;
        description = ''
          Test
        '';
      };

      pre-commit-check = l.mkOption {
        type = l.types.package;
        description = ''
          Test
        '';
      };
    };
  };


  mkFlake-IN-option = l.mkOption {
    type = mkFlake-IN-submodule;
    description = "";
  };


  mkFlake-OUT-option = l.mkOption {
    type = mkFlake-OUT-submodule;
    description = "";
  };


  mkProject-IN-option = l.mkOption {
    type = mkProject-IN-submodule;
    description = "";
  };


  mkProject-OUT-option = l.mkOption {
    type = mkProject-OUT-submodule;
    description = "";
  };


  mkShell-IN-option = l.mkOption {
    type = mkShell-IN-submodule;
    description = "";
  };


  mkShell-OUT-option = l.mkOption {
    type = mkShell-OUT-submodule;
    description = "";
  };


  mkFlake = l.mkOption {
    type = apiFuncType mkFlake-IN-submodule mkFlake-OUT-submodule;
    description = ''
      The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

      In this document:
        - Options for the input attrset are prefixed by `mkFlake.<in>`.
        - The returned attrset contans attributes prefixed by `mkFlake.<out>`.
    '';
    example = l.literalExpression ''
      # ./flake.nix
      outputs = inputs: inputs.iogx.lib.mkFlake {
        inherit inputs;
        repoRoot = ./.;
        systems = [ "x86_64-linux" "x86_64-darwin" ];
        outputs = { repoRoot, inputs, pkgs, lib, system }: [];
      };
    '';
  };


  mkProject = l.mkOption {
    description = "asd";
    type = apiFuncType mkProject-IN-submodule mkProject-OUT-submodule;
  };


  mkShell = l.mkOption {
    description = "asd";
    type = apiFuncType mkShell-IN-submodule mkShell-OUT-submodule;
  };


  apiFuncType = type-IN: type-OUT: l.mkOptionType {
    name = "core-API-function";
    description = "core API function";
    # descriptionClass = "noun";
    getSubOptions = prefix:
      type-IN.getSubOptions (prefix ++ [ "<in>" ]) //
      type-OUT.getSubOptions (prefix ++ [ "<out>" ]);
  };

in

{
  inherit mkFlake mkProject mkShell;
  inherit mkFlake-IN-option mkProject-IN-option mkShell-IN-option;
}
