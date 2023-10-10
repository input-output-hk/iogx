iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToLocalMarkDownLink x x;


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


  mkShell-IN = l.mkOption {
    type = mkShell-IN-submodule;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkShell-OUT = l.mkOption {
    type = mkShell-OUT-submodule;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkShell = l.mkOption {
    description = ''
      The `lib.iogx.mkShell` function takes an attrset of options and returns a normal `devShell` with an additional attribute named ${link "mkShell.<out>.pre-commit-check"}.

      In this document:
        - Options for the input attrset are prefixed by `mkShell.<in>`.
        - The returned attrset contains the attributes prefixed by `mkShell.<out>`.
    '';
    type = utils.mkApiFuncOptionType mkShell-IN.type mkShell-OUT.type;
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


in

{
  inherit mkShell;
  "mkShell.<in>" = mkShell-IN;
}
