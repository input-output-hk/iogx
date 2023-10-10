iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ./utils.nix iogx-inputs;

  link = x: utils.headerToLocalMarkDownLink x x;


  flake-submodule = l.types.submodule {
    options = {
      description = l.mkOption {
        default = "";
        type = l.types.str;
        description = ''
          Arbitrary description for the flake. 

          This string is displayed when running `nix flake info` and other flake 
          commands. 

          It can be a short title for your project. 
        '';
        example = l.literalExpression ''
          # flake.nix 
          { 
            description = "My Haskell Project";
            inputs = {};
            outputs = _: {};
            nixConfig = {};
          }
        '';
      };

      inputs = l.mkOption {
        type = l.types.attrs;
        default = {};
        description = ''
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
        '';
        example = l.literalExpression ''
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
        '';
      };

      outputs = l.mkOption {
        type = l.types.functionTo l.types.attrs;
        default = _: {};
        description = ''
          Your flake `outputs` are produced using ${link "mkFlake"}.
        '';
        example = l.literalExpression ''
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
        '';
      };

      nixConfig = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = {};
        description = ''
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
        '';
        example = l.literalExpression ''
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
        '';
      };
    };
  };


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
          Whether to enable this pre-commit hook.

          If `false`, the hook will not be installed.

          If `true`, the hook will become available in the shell: 
          ```bash 
          pre-commit run <hook-name>
          ```
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            preCommit = {
              cabal-fmt.enable = system != "x86_64-darwin";
            };
          }
        '';
      };

      package = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          The package that provides the hook.

          The `nixpkgs.lib.getExe` function will be used to extract the program to run.

          If unset or `null`, the default package will be used.

          In general you don't want to override this, especially for the Haskell tools, because the default package will be the one that matches the compiler used by your project.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            preCommit = {
              cabal-fmt.enable = true;
              cabal-fmt.package = repoRoot.nix.patched-cabal-fmt;
            };
          }
        '';
      };

      extraOptions = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Extra command line options to be passed to the hook.

          Each hooks knows how run itself, and will be called with the correct command line arguments.
          
          However you can *append* additional options to a tool's command by setting this field.
        '';
        example = l.literalExpression ''
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
        '';
      };
    };
  };


  tools-submodule = l.types.submodule {
    options = {
      haskellCompilerVersion = l.mkOption {
        default = null;
        type = l.types.nullOr (l.types.enum [ "ghc8107" "ghc928" "ghc927" "ghc962" "ghc810" "ghc92" "ghc96" ]);
        description = ''
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

          IOGX does this automatically when creating a shell with ${link "mkHaskellProject.<in>.shellArgs"}.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.haskellCompilerVersion = "ghc8107";
          }
        '';
      };

      cabal-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `cabal-fmt` executable.

          If unset or `null`, a default `cabal-fmt` will be provided, which is independent of ${link "mkShell.<in>.tools.haskellCompilerVersion"}.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.cabal-fmt = repoRoot.nix.patched-cabal-fmt;
          }
        '';
      };

      cabal-install = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `cabal-install` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.cabal-install = repoRoot.nix.patched-cabal-install;
          }
        '';
      };

      haskell-language-server = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `haskell-language-server` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.haskell-language-server = repoRoot.nix.patched-haskell-language-server;
          }
        '';
      };

      haskell-language-server-wrapper = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `haskell-language-server-wrapper` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.haskell-language-server-wrapper = repoRoot.nix.pathced-haskell-language-server-wrapper;
          }
        '';
      };

      fourmolu = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `fourmolu` executable.

          If unset or `null`, a default `fourmolu` will be provided, which is independent of ${link "mkShell.<in>.tools.haskellCompilerVersion"}.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.fourmolu = repoRoot.nix.patched-fourmolu;
          }
        '';
      };

      hlint = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `hlint` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.hlint = repoRoot.nix.patched-hlint;
          }
        '';
      };

      stylish-haskell = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `stylish-haskell` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.stylish-haskell = repoRoot.nix.patched-stylish-haskell;
          }
        '';
      };

      ghcid = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `ghcid` executable.

          If unset or `null`, ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to select a suitable derivation.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.ghcid = repoRoot.nix.patched-ghcid;
          }
        '';
      };

      shellcheck = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `shellcheck` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.shellcheck = repoRoot.nix.patched-shellcheck;
          }
        '';
      };

      prettier = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `prettier` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.prettier = repoRoot.nix.patched-prettier;
          }
        '';
      };

      editorconfig-checker = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `editorconfig-checker` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.editorconfig-checker = repoRoot.nix.patched-editorconfig-checker;
          }
        '';
      };

      nixpkgs-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `nixpkgs-fmt` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.nixpkgs-fmt = repoRoot.nix.patched-nixpkgs-fmt;
          }
        '';
      };

      optipng = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `optipng` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.optipng = repoRoot.nix.patched-optipng;
          }
        '';
      };

      purs-tidy = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `purs-tidy` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.purs-tidy = repoRoot.nix.patched-purs-tidy;
          }
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
          The `cabal-fmt` pre-commit hook.
        '';
      };

      stylish-haskell = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `stylish-haskell` pre-commit hook.
        '';
      };

      fourmolu = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `fourmolu` pre-commit hook.
        '';
      };

      hlint = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `hlint` pre-commit hook.
        '';
      };

      shellcheck = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `shellcheck` pre-commit hook.
        '';
      };

      prettier = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `prettier` pre-commit hook.
        '';
      };

      editorconfig-checker = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `editorconfig-checker` pre-commit hook.
        '';
      };

      nixpkgs-fmt = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `nixpkgs-fmt` pre-commit hook.
        '';
      };

      optipng = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `optipng` pre-commit hook.
        '';
      };

      purs-tidy = l.mkOption {
        type = pre-commit-hook-submodule;
        default = default-pre-commit-hook;
        description = ''
          The `purs-tidy` pre-commit hook.
        '';
      };
    };
  };


  script-submodule = l.types.submodule {
    options = {
      exec = l.mkOption {
        type = l.types.str;
        description = ''
          Bash code to be executed when the script is run.

          This field is required.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            scripts = {
              foo = {
                exec = '''
                  echo "Hello, world!"
                ''';
              };
            };
          }
        '';
      };

      description = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          A string that will appear next to the script name when printed.
        '';
        example = l.literalExpression ''
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
        '';
      };

      group = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          A string to tag the script.

          This will be used to group scripts together so that they look prettier and more organized when listed. 
        '';
        example = l.literalExpression ''
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
        '';
      };

      enable = l.mkOption {
        type = l.types.bool;
        default = true;
        description = ''
          Whether to enable this script.

          This can be used to include scripts conditionally.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            scripts = {
              foo = {
                enable = pkgs.stdenv.hostPlatform.isLinux;
                exec = '''
                  echo "I only run on Linux."
                ''';
              };
            };
          }
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
          Whether to enable combined haddock for your project.
        '';
      };

      packages = l.mkOption {
        type = l.types.listOf l.types.str;
        default = [ ];
        description = ''
          The list of cabal package names to include in the combined Haddock.
        '';
      };

      prologue = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          A string acting as prologue for the combined Haddock.
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

      enable = l.mkOption {
        type = l.types.bool;
        default = false;
        description = ''
          Whether to enable support for a Read The Docs site.
        '';
      };

      siteFolder = l.mkOption {
        type = l.types.str;
        description = ''
          A Nix string representing a path, relative to the repository root, to your site folder containing the `conf.py` file.
        '';
        example = l.literalExpression ''
          # project.nix
          { repoRoot, inputs, pkgs, lib, system }:
          
          lib.iogx.mkHaskellProject {
            readTheDocs.siteFolder = "./doc/read-the-docs-site";
          }
        '';
      };

      sphinxToolchain = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A python environment with the required packages to build your site using sphinx.

          Normally you don't need to override this.
        '';
        example = l.literalExpression ''
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

          You almost certainly want to do `inherit inputs;` here (see the example in ${link "mkFlake"})
        '';
      };

      repoRoot = l.mkOption {
        type = l.types.path;
        description = ''
          The root of your repository.

          If not set, this will default to the folder containing the `flake.nix` file, using `inputs.self`.
        '';
        default = null;
        example = l.literalExpression "./.";
      };

      systems = l.mkOption {
        type = l.types.listOf (l.types.enum [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ]);
        description = ''
          The systems you want to build for.

          The ${link "mkFlake.<in>.outputs"} function will be called once for each system.
        '';
        default = [ "x86_64-linux" "x86_64-darwin" ];
        defaultText = l.literalExpression ''[ "x86_64-linux" "x86_64-darwin" ]'';
      };

      outputs = l.mkOption {
        type = l.types.functionTo (l.types.listOf l.types.attrs);
        example = l.literalExpression ''
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
        '';
        description = ''
          A function that is called once for each system in ${link "mkFlake.<in>.systems"}.

          This is the most important option as it will determine your flake outputs.

          `outputs` receives an attrset and must return a list of attrsets.

          The returned attrsets are recursively merged top-to-bottom. 

          Each of the input attributes is documented below.

          #### `repoRoot`

          Ordinarily you would use the `import` keyword to import nix files, but you can use the `repoRoot` variable instead.

          `repoRoot` is an attrset that can be used to reference the contents of your repository folder instead of using the `import` keyword.

          Its value is set to the path of ${link "mkFlake.<in>.repoRoot"}.

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

          Any nix file that is referenced this way will receive the attrset `{ repoRoot, inputs, pkgs, system, lib }`, just like ${link "mkFlake.<in>.outputs"}.

          Using the `repoRoot` argument is optional, but it has the advantage of not having to thread the standard arguments (especially `pkgs` and `inputs`) all over the place.

          ### `inputs`

          Your flake inputs as defined in ${link "mkFlake.<in>.inputs"}.

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

          A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your ${link "mkFlake.<in>.systems"}, and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

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
        '';
      };

      flake = l.mkOption {
        type = l.types.attrs;
        default = { };
        description = ''
          A flake-like attrset.

          You can place additional flake outputs here, which will be recursively updated with the attrset from ${link "mkFlake.<in>.outputs"}.

          This is a good place to put system-independent values like a `lib` attrset or pure Nix values.
        '';
        example = l.literalExpression ''
          {
            lib.bar = _: null;

            packages.x86_64-linux.foo = null;
            devShells.x86_64-darwin.bar = null;

            networks = {
              prod = { };
              dev = { };
            };
          }
        '';
      };

      nixpkgsArgs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Internally, IOGX calls `import inputs.nixpkgs {}` for each of your ${link "mkFlake.<in>.systems"}.

          Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.
        '';
        default = {
          config = { };
          overlays = [ ];
        };
        example = l.literalExpression ''
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
        '';
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


  mkHaskellProject-IN-submodule = l.types.submodule {
    options = {
      cabalProject = l.mkOption {
        type = l.types.raw;
        default = { };
        description = ''
          The original `cabalProject`. 
          
          You most likely want to get one using [`haskell.nix:cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=cabalProjec#cabalproject).

          You should use `flake.variants` to provide support for profiling, different GHC versions, and any other additional configuration.

          The variants will be available in ${link "mkHaskellProject.<out>.variants"}.
        '';
        example = l.literalExpression ''
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
        '';
      };

      shellArgs = l.mkOption {
        type = l.types.functionTo l.types.attrs;
        default = cabalProject: {
          tools.haskellCompilerVersion = cabalProject.args.compiler-nix-name;
          name = cabalProject.args.name;
        };
        description = ''
          Arguments for ${link "mkShell"}.

          This is a function that is called once with the ${link "mkHaskellProject.<in>.cabalProject"} 
          and then once for each project variant. 

          Internally these `shellArgs` are passed to ${link "mkShell"}.

          The shells will be available in:
          - ${link "mkHaskellProject.<out>.devShell"}.
          - ${link "mkHaskellProject.<out>.variants.<name>.devShell"}.
        '';
      };

      # TODO rename
      includeMingwW64HydraJobs = l.mkOption {
        type = l.types.bool;
        default = false; # TODO Document Better
        description = ''
          When set to `true` then ${link "mkHaskellProject.<out>.flake"} will include `hydraJobs.mingwW64`
          for your `cabalProject.projectCross.mingwW64`.
        '';
      };

      combinedHaddock = l.mkOption {
        type = combined-haddock-submodule;
        default = default-combined-haddock;
        description = ''
          Configuration for a combined Haddock.

          When enabled, your ${link "mkHaskellProject.<in>.readTheDocs"} site will have access to Haddock symbols for your Haskell packages.

          Combining Haddock artifacts takes a significant amount of time and may slow down CI.

          The combined Haddock will be available in:
          - ${link "mkHaskellProject.<out>.combined-haddock"}
          - ${link "mkHaskellProject.<out>.cross.<name>.combined-haddock"}
        '';
        example = l.literalExpression ''
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
        '';
      };

      readTheDocs = l.mkOption {
        type = read-the-docs-submodule;
        default = default-read-the-docs;
        description = ''
          Configuration for your [`read-the-docs`](https://readthedocs.org) site. 

          If no site is required, this option can be omitted.

          The shells generated by ${link "mkHaskellProject.<in>.shellArgs"} will be 
          augmented with several scripts to make developing your site easier, 
          grouped under the tag `read-the-docs`.

          The Read The Docs site derivation will be available in:
          - ${link "mkHaskellProject.<out>.read-the-docs-site"}
          - ${link "mkHaskellProject.<out>.variants.<name>.read-the-docs-site"}
        '';
        example = l.literalExpression ''
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
        '';
      };
    };
  };


  mkShell-IN-submodule = l.types.submodule {
    options = {

      name = l.mkOption {
        type = l.types.str;
        default = "nix-shell";
        description = ''
          This field will be used as the shell's derivation name and it will also be used to fill in the default values for ${link "mkShell.<in>.prompt"} and ${link "mkShell.<in>.welcomeMessage"}.
        '';
      };

      prompt = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
        description = ''
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
        '';
      };

      welcomeMessage = l.mkOption {
        type = l.types.nullOr l.types.str;
        default = null;
        description = ''
          When entering the shell, this welcome message will be printed.

          The same caveat about escaping back slashes in ${link "mkShell.<in>.prompt"} applies here.

          This field is optional and defaults to a simple welcome message using the ${link "mkShell.<in>.name"} field.
        '';
      };

      packages = l.mkOption {
        type = l.types.listOf l.types.package;
        default = [ ];
        description = ''
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

          If you `cabalProject` (coming from ${link "mkHaskellProject"}) is in scope, you could use `hsPkgs` to obtain some useful binaries:
          ```nix
          packages = [
            cabalProject.hsPkgs.cardano-cli.components.exes.cardano-cli
            cabalProject.hsPkgs.cardano-node.components.exes.cardano-node
          ];
          ```

          Be careful not to reference your project's own cabal packages via `hsPkgs`. 

          If you do, then `nix develop` will build your project every time you enter the shell, and it will fail to do so if there are Haskell compiler errors.
        '';
      };

      scripts = l.mkOption {
        type = l.types.lazyAttrsOf script-submodule;
        default = { };
        description = ''
          Custom scripts for your shell.

          `scripts` is an attrset where each attribute name is the script name each the attribute value is an attrset.

          The attribute names (`foobar` and `waz` in the example above) will be available in your shell as commands under the same name.
        '';
        example = l.literalExpression ''
          scripts = {

            foobar = {
              exec = '''
                # Bash code to be executed whenever the script `foobar` is run.
                echo "Delete me from your nix/shell.nix!"
              ''';
              description = '''
                You might want to delete the foobar script.
              ''';
              group = "bazwaz";
              enable = true;
            };

            waz.exec = '''
              echo "I don't have a group!"
            ''';
          };
        '';
      };

      env = l.mkOption {
        type = l.types.lazyAttrsOf l.types.raw;
        default = { };
        description = ''
          Custom environment variables. 

          Considering the example above, the following bash code will be executed every time you enter the shell:

          ```bash 
          export PGUSER="postgres"
          export THE_ANSWER="42"
          ```
        '';
        example = l.literalExpression ''
          env = {
            PGUSER = "postgres";
            THE_ANSWER = 42;
          };
        '';
      };

      shellHook = l.mkOption {
        type = l.types.str;
        default = "";
        description = ''
          Standard nix `shellHook`, to be executed every time you enter the shell.
        '';
        example = l.literalExpression ''
          shellHook = '''
            # Bash code to be executed when you enter the shell.
            echo "I'm inside the shell!"
          ''';
        '';
      };

      tools = l.mkOption {
        type = tools-submodule;
        default = { };
        description = ''
          An attrset of packages to be made available in the shell.

          This can be used to override the default derivations used by IOGX.

          The value of ${link "mkShell.<in>.tools.haskellCompilerVersion"} will be used to determine the version of the Haskell tools (e.g. `cabal-install` or `stylish-haskell`).
        '';
      };

      preCommit = l.mkOption {
        type = pre-commit-submodule;
        default = { };
        description = ''
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
        '';
        example = l.literalExpression ''
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
        '';
      };
    };
  };


  mkHaskellProject-OUT-submodule = l.types.submodule {
    options = {
      iogx = l.mkOption {
        description = ''
          This in an attrset containing all the derivations for your project.

          You will want to consume this value in your flake ${link "mkFlake.<in>.outputs"}, as shown in the example above.
        '';
        example = l.literalExpression ''
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
        '';
        type = l.types.submodule {
          options = {
            flake = l.mkOption {
              type = l.types.attrs;
              description = ''
                An attribute set that can be included in your ${link "mkFlake.<in>.outputs"} directly.

                It contains all the derivations for your project, but does not include project variants.

                If you set ${link "mkHaskellProject.<in>.includeMingwW64HydraJobs"} to `true`, then 
                this attrset will also include `hydraJobs.mingwW64`.

                This also automatically adds the `required` job using ${link "mkHydraRequiredJob"}.

                - `cabalProject` = ${link "mkHaskellProject.<out>.cabalProject"}
                - `devShells.default` = ${link "mkHaskellProject.<out>.devShell"}
                - `packages.*` = ${link "mkHaskellProject.<out>.packages"}
                - `packages.combined-haddock` = ${link "mkHaskellProject.<out>.combined-haddock"}
                - `packages.read-the-docs-site` = ${link "mkHaskellProject.<out>.read-the-docs-site"}
                - `packages.pre-commit-check` = ${link "mkHaskellProject.<out>.pre-commit-check"}
                - `apps.*` = ${link "mkHaskellProject.<out>.apps"}
                - `checks.*` = ${link "mkHaskellProject.<out>.checks"}
                - `hydraJobs.*` = ${link "mkHaskellProject.<out>.hydraJobs"}
                - `hydraJobs.combined-haddock` = ${link "mkHaskellProject.<out>.combined-haddock"}
                - `hydraJobs.read-the-docs-site` = ${link "mkHaskellProject.<out>.read-the-docs-site"} 
                - `hydraJobs.pre-commit-check` = ${link "mkHaskellProject.<out>.pre-commit-check"} 
                - `hydraJobs.mingwW64` = ${link "mkHaskellProject.<out>.cross.mingwW64.hydraJobs"}
                - `hydraJobs.required` = ${link "mkHydraRequiredJob"}
              '';
              example = l.literalExpression ''
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
              '';
            };

            packages = l.mkOption {
              type = l.types.attrs;
              description = ''
                A attrset containing the cabal executables, testsuites and benchmarks.

                The keys are the cabal target names, and the values are the derivations.

                IOGX will fail to evaluate if some of you cabal targets have the same name.
              '';
            };

            apps = l.mkOption {
              type = l.types.attrs;
              description = ''
                A attrset containing the cabal executables, testsuites and benchmarks.

                The keys are the cabal target names, and the values are the program paths.

                IOGX will fail to evaluate if some of you cabal targets have the same name.
              '';
            };

            checks = l.mkOption {
              type = l.types.attrs;
              description = ''
                A attrset containing the cabal testsuites.

                When these derivations are **built**, the actual tests will be run as part of the build.

                The keys are the cabal target names, and the values are the derivations.

                IOGX will fail to evaluate if some of you cabal targets have the same name.
              '';
            };

            hydraJobs = l.mkOption {
              type = l.types.attrs;
              description = ''
                A jobset containing `packages`, `checks`, `devShells.default` and `haskell.nix`'s `plan-nix` and `roots`.

                The `devShell` comes from your implementation of ${link "mkHaskellProject.<in>.shellArgs"}.

                This attrset does not contain:
                - ${link "mkHaskellProject.<out>.combined-haddock"}
                - ${link "mkHaskellProject.<out>.read-the-docs-site"}
                - ${link "mkHaskellProject.<out>.pre-commit-check"}

                If you need those you can use ${link "mkHaskellProject.<out>.iogx.defaultFlakeOutputs"}, or you can reference them directly from the `iogx` attrset.
              '';
            };

            devShell = l.mkOption {
              type = l.types.package;
              description = ''
                The `devShell` as provided by your implementation of ${link "mkHaskellProject.<in>.shellArgs"}.
              '';
            };

            read-the-docs-site = l.mkOption {
              type = l.types.package;
              description = ''
                The derivation for your ${link "mkHaskellProject.<in>.readTheDocs"}.
              '';
            };

            combined-haddock = l.mkOption {
              type = l.types.package;
              description = ''
                The derivation for your ${link "mkHaskellProject.<in>.combinedHaddock"}.
              '';
            };

            pre-commit-check = l.mkOption {
              type = l.types.package;
              description = ''
                The derivation for the ${link "mkShell.<in>.preCommit"} coming from ${link "mkHaskellProject.<in>.shellArgs"}.
              '';
            };

            variants = l.mkOption {
              type = l.types.attrs;
              description = ''
                This attribute contains the variants for your project, 
                as defined in your ${link "mkHaskellProject.<in>.cabalProject"}`.flake.variants`.

                Each variant has exaclty the same attributes as the main project.

                See the example above for more information.
              '';
              example = l.literalExpression ''
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
              '';
            };

            cross = l.mkOption {
              type = l.types.attrs;
              description = ''
                This attribute contains cross-compilation variants for your project.

                Each variant only has two attributes: 
                - `cabalProject` the original project coming from `projectCross.<name>`
                - `hydraJobs` that can be included directly in your flake outputs
              '';
              example = l.literalExpression ''
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
              '';
            };
          };
        };
      };
    };
  };


  mkShell-OUT-submodule = l.types.submodule {
    options = {

      pre-commit-check = l.mkOption {
        type = l.types.package;
        description = ''
          A derivation that when built will run all the installed shell hooks.

          The hooks are configured in ${link "mkShell.<in>.preCommit"}.

          This derivation can be included in your `packages` and in `hydraJobs`.
        '';
        example = l.literalExpression ''
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
        '';
      };
    };
  };


  mkFlake-IN = l.mkOption {
    type = mkFlake-IN-submodule;
    description = "";
  };


  mkFlake-OUT-option = l.mkOption {
    type = l.types.attrs;
    description = ''
      The ${link "mkFlake" "mkFlake"} function returns the final flake outputs.

      The optional attrset defined in ${link "mkFlake.<in>.flake"} will 
      be updated with the attrset obtained by merging the attrsets returned by ${link "mkFlake.<in>.outputs"}.
    '';
  };


  mkHaskellProject-IN = l.mkOption {
    type = mkHaskellProject-IN-submodule;
    description = "";
  };


  mkHaskellProject-OUT-option = l.mkOption {
    type = mkHaskellProject-OUT-submodule;
    description = "";
  };


  mkShell-IN = l.mkOption {
    type = mkShell-IN-submodule;
    description = "";
  };


  mkShell-OUT-option = l.mkOption {
    type = mkShell-OUT-submodule;
    description = "";
  };


  flake = l.mkOption {
    type = flake-submodule;
    description = "";
  };


  mkFlake = l.mkOption {
    type = apiFuncType mkFlake-IN-submodule mkFlake-OUT-option.type;
    description = ''
      The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

      In this document, options for the input attrset are prefixed by `mkFlake.<in>`.
    '';
    example = l.literalExpression ''
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
    '';
  };


  mkHaskellProject = l.mkOption {
    description = ''
      The `lib.iogx.mkHaskellProject` function takes an attrset of options and returns a `cabalProject` with the `iogx` overlay.

      In this document:
        - Options for the input attrset are prefixed by `mkHaskellProject.<in>`.
        - The returned attrset contains the attributes prefixed by `mkHaskellProject.<out>.iogx`.
    '';
    type = apiFuncType mkHaskellProject-IN-submodule mkHaskellProject-OUT-submodule;
    example = l.literalExpression ''
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
    '';
  };


  mkShell = l.mkOption {
    description = ''
      The `lib.iogx.mkShell` function takes an attrset of options and returns a normal `devShell` with an additional attribute named ${link "mkShell.<out>.pre-commit-check"}.

      In this document:
        - Options for the input attrset are prefixed by `mkShell.<in>`.
        - The returned attrset contains the attributes prefixed by `mkShell.<out>`.
    '';
    type = apiFuncType mkShell-IN-submodule mkShell-OUT-submodule;
    example = l.literalExpression ''
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
            exec = '''
              echo "Hello, World!"
            ''';
          };
        };
        shellHook = "";
        preCommit = {
          shellcheck.enable = true;
        };
        tools.haskellCompilerVersion = "ghc8103";
      };
    '';
  };


  apiFuncType = type-IN: type-OUT: l.mkOptionType {
    name = "core-API-function";
    description = "core API function";
    getSubOptions = prefix:
      type-IN.getSubOptions (prefix ++ [ "<in>" ]) //
      type-OUT.getSubOptions (prefix ++ [ "<out>" ]);
  };

in

{
  inherit flake; 
  inherit mkFlake mkHaskellProject mkShell;
  inherit mkFlake-IN mkHaskellProject-IN mkShell-IN;
}