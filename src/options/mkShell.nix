iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToMarkDownLink x x;

  tools-submodule = l.types.submodule {
    options = {
      haskellCompilerVersion = l.mkOption {
        default = null;
        type = l.types.nullOr l.types.str;
        description = ''
          The haskell compiler version.

          Any value that is accepected by `haskell.nix:compiler-nix-name` is valid, e.g: `ghc8107`, `ghc92`, `ghc963`.

          This determines the version of other tools like `cabal-install` and `haskell-language-server`.

          If this option is unset of null, then no Haskell tools will be made available in the shell.

          However if you enable some Haskell-specific ${
            link "mkShell.<in>.preCommit"
          } hooks, then 
          that Haskell tool will be installed automatically using `ghc8107` as the default compiler version.

          When using ${
            link "mkHaskellProject.<in>.shellArgs"
          }, this option is automatically set to 
          the same value as the project's (or project variant's) `compiler-nix-name`.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.haskellCompilerVersion = "ghc8107";
            # ^^^^^ This will bring the haskell tools in your shell
          }
        '';
      };

      cabal-fmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `cabal-fmt` executable.

          If unset or `null`, a default `cabal-fmt` will be provided, which is independent of ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          }.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

          If unset or `null`, a default `fourmolu` will be provided, which is independent of ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          }.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

          If unset or `null`, ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to select a suitable derivation.
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

      nixfmt-classic = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `nixfmt-classic` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.nixfmt-classic = repoRoot.nix.patched-nixfmt-classic;
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

      rustfmt = l.mkOption {
        type = l.types.nullOr l.types.package;
        default = null;
        description = ''
          A package that provides the `rustfmt` executable.

          If unset or `null`, the most recent version available will be used.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          lib.iogx.mkShell {
            tools.rustfmt = repoRoot.nix.patched-rustfmt;
          }
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
          This field will be used as the shell's derivation name and it will also be used to fill in the default values for ${
            link "mkShell.<in>.prompt"
          } and ${link "mkShell.<in>.welcomeMessage"}.
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

          The same caveat about escaping back slashes in ${
            link "mkShell.<in>.prompt"
          } applies here.

          This field is optional and defaults to a simple welcome message using the ${
            link "mkShell.<in>.name"
          } field.
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

          If you `cabalProject` (coming from ${
            link "mkHaskellProject"
          }) is in scope, you could use `hsPkgs` to obtain some useful binaries:
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

          The value of ${
            link "mkShell.<in>.tools.haskellCompilerVersion"
          } will be used to determine the version of the Haskell tools (e.g. `cabal-install` or `stylish-haskell`).
        '';
      };

      preCommit = l.mkOption {
        type = l.types.lazyAttrsOf l.types.attrs;
        default = { };
        description = ''
          Configuration for arbitrary pre-commit hooks, passed verbatim to [`pre-commit-hooks-nix`](https://github.com/cachix/pre-commit-hooks.nix#custom-hooks).

          This is an attrset where each attribute name is the name of the hook, and each attribute value is the attrset of options for a [`custom-hook`](https://github.com/cachix/pre-commit-hooks.nix#custom-hooks).

          There is an additional string option named `extraOptions` for convenience, which is appended to [`entry`](https://github.com/cachix/pre-commit-hooks.nix/blob/ffa9a5b90b0acfaa03b1533b83eaf5dead819a05/modules/pre-commit.nix#L54).

          The `pre-commit` executable will be made available in the shell, and should be used to test and run your hooks.

          Some hooks are pre-configured by default and can be enabled by setting the `enable` option to `true`.

          For these hooks, the `extraOptions` option becomes especially relevant.

          The list of pre-configured hooks is presented below: 

          - `cabal-fmt`
          - `stylish-haskell`
          - `shellcheck`
          - `prettier`
          - `editorconfig-checker`
          - `nixfmt-classic`
          - `optipng`
          - `fourmolu`
          - `hlint`
          - `purs-tidy`

          When enabled, some of the above hooks expect to find a configuration file in the root of the repository:

          | Hook Name | Config File | 
          | --------- | ----------- |
          | `stylish-haskell` | `.stylish-haskell.yaml` |
          | `editorconfig-checker` | `.editorconfig` |
          | `fourmolu` | `fourmolu.yaml` (note the missing dot `.`) |
          | `hlint` | `.hlint.yaml` |
          | `hindent` | `.hindent.yaml` |

          Currently there is no way to change the location of the configuration files.

          Each pre-configured hook knows which file extensions to look for, which files to ignore, and how to modify the files in-place.
        '';
        example = l.literalExpression ''
          # shell.nix 
          { repoRoot, inputs, pkgs, lib, system }:

          lib.iogx.mkShell {
            preCommit = {
              cabal-fmt.enable = true;
              cabal-fmt.extraOptions = "--tabular";

              stylish-haskell.enable = false;
              stylish-haskell.extraOptions = "";

              shellcheck.enable = false;
              shellcheck.extraOptions = "";

              prettier.enable = false;
              prettier.extraOptions = "";

              editorconfig-checker.enable = false;
              editorconfig-checker.extraOptions = "";

              nixfmt-classic.enable = false;
              nixfmt-classic.extraOptions = "";

              optipng.enable = false;
              optipng.extraOptions = "";

              fourmolu.enable = true;
              fourmolu.extraOptions = "--ghc-option -XOverloadedStrings";

              hlint.enable = false;
              hlint.extraOptions = "";

              purs-tidy.enable = false;
              purs-tidy.extraOptions = "";

              # https://github.com/cachix/pre-commit-hooks.nix#custom-hooks
              my-custom-hook = {
                extraOptions = [ "--foo" "--bar" ];

                enable = true;
                name = "Unit tests";
                entry = "make check";
                files = "\\.(c|h)$";
                types = [ "text" "c" ];
                excludes = [ "irrelevant\\.c" ];
                language = "system";
                pass_filenames = false;
              };
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
      The `lib.iogx.mkShell` function takes an attrset of options and returns a normal `devShell` with an additional attribute named ${
        link "mkShell.<out>.pre-commit-check"
      }.

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
        tools.haskellCompilerVersion = "ghc8107";
      };
    '';
  };

in {
  inherit mkShell;
  "mkShell.<in>" = mkShell-IN;
}
