iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToLocalMarkDownLink x x;


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
          A Nix string representing a path, relative to the repository root, to 
          your site folder containing the `conf.py` file.
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
          A python environment with the required packages to build your site 
          using sphinx.

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
    enable = false;
    siteFolder = null;
    sphinxToolchain = null;
  };


  mkHaskellProject-IN-submodule = l.types.submodule {
    options = {
      cabalProject = l.mkOption {
        type = l.types.attrs;
        default = { };
        description = ''
          The original `cabalProject`. 
          
          You most likely want to get one using 
          [`haskell.nix:cabalProject'`](https://input-output-hk.github.io/haskell.nix/reference/library.html?highlight=cabalProjec#cabalproject)
          like in the example above.

          You should use `flake.variants` to provide support for profiling, different GHC versions, and any other additional configuration.

          The variants will be available in ${link "mkHaskellProject.<out>.variants"}.
        '';
        example = l.literalExpression ''
          # nix/project.nix 
          { repoRoot, inputs, lib, system, ... }:

          lib.iogx.mkHaskellProject {
            cabalProject = pkgs.haskell-nix.cabalProject' ({ pkgs, config, ...) {
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
            });
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

          This is a function that is called once with the original
          ${link "mkHaskellProject.<in>.cabalProject"} (coming from `haskell.nix`),
          and then once for each project variant. 

          Internally these `shellArgs` are passed to ${link "mkShell"}.

          The shells will be available in:
          - ${link "mkHaskellProject.<out>.devShell"}.
          - ${link "mkHaskellProject.<out>.variants.<name>.devShell"}.
        '';
      };

      includeProfiledHydraJobs = l.mkOption {
        type = l.types.bool;
        default = false;
        example = l.literalExpression ''
          # outputs.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          let 
            project = lib.iogx.mkHaskellProject {
              includeProfiledHydraJobs = true;
            };
          in 
          [
            (
              project.flake 
              # ^^^^^ Includes: hydraJobs.profiled = project.variants.profiled.hydraJobs;
            )
          ]
          ```
        '';
        description = ''
          When set to `true` then ${link "mkHaskellProject.<out>.flake"} will include:
          ```nix 
          hydraJobs.profiled = project.variants.profiled.hydraJobs;
          ```

          This is just a convenience option, you can always reference the jobs directly:
          ```nix
          # outputs.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          let 
            project = lib.iogx.mkHaskellProject {
              includeProfiledHydraJobs = false;
            };
          in 
          [
            {
              hydraJobs.profiled = project.variants.profiled.hydraJobs;
            }
          ]
          ```

          This option assumes that you have defined a flake variant called `profiled` in your
          haskell.nix `cabalProject` (see the example above).
        '';
      };

      includeMingwW64HydraJobs = l.mkOption {
        type = l.types.bool;
        default = false;
        example = l.literalExpression ''
          # outputs.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          let 
            project = lib.iogx.mkHaskellProject {
              includeMingwW64HydraJobs = true;
            };
          in 
          [
            (
              project.flake 
              # ^^^^^ Includes: hydraJobs.mingwW64 = project.cross.mingwW64.hydraJobs;
            )
          ]
          ```
        '';
        description = ''
          When set to `true` then ${link "mkHaskellProject.<out>.flake"} will include:
          ```nix 
          hydraJobs.mingwW66 = project.cross.mingwW64.hydraJobs
          ```

          This is just a convenience option, you can always reference the jobs directly:
          ```nix
          # outputs.nix 
          { repoRoot, inputs, pkgs, lib, system }:
          let 
            project = lib.iogx.mkHaskellProject {
              includeMingwW64HydraJobs = false;
            };
          in 
          [
            {
              hydraJobs.mingwW64 = project.cross.mingwW64.hydraJobs;
            }
          ]
          ```
        '';
      };

      combinedHaddock = l.mkOption {
        type = combined-haddock-submodule;
        default = default-combined-haddock;
        description = ''
          Configuration for a combined Haddock.

          When enabled, your ${link "mkHaskellProject.<in>.readTheDocs"} site will have access to Haddock symbols for your Haskell packages.

          Combining Haddock artifacts takes a significant amount of time and may slow down CI.

          The combined Haddock(s) will be available in:
          - ${link "mkHaskellProject.<out>.combined-haddock"}
          - ${link "mkHaskellProject.<out>.variants.<name>.combined-haddock"}
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

          The Read The Docs site derivation(s) will be available in:
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


  mkHaskellProject-OUT-submodule = l.types.submodule {
    options = {
      flake = l.mkOption {
        type = l.types.attrs;
        description = ''
          An attribute set that can be included in your ${link "mkFlake.<in>.outputs"} directly.

          For simple Haskell projects with no flake variants, this is all you need.

          It contains all the derivations for your project, but does not include project variants.

          If you set ${link "mkHaskellProject.<in>.includeMingwW64HydraJobs"} to `true`, then 
          this attrset will also include `hydraJobs.mingwW64`.

          This also automatically adds the `hydraJobs.required` job using ${link "mkHydraRequiredJob"}.

          Below is a list of all its attributes:

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
          - `hydraJobs.mingwW64` = ${link "mkHaskellProject.<out>.cross.mingwW64.hydraJobs"} (conditionally)
          - `hydraJobs.required` = ${link "mkHydraRequiredJob"}
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

          If you need those you can use ${link "mkHaskellProject.<out>.flake"}, or you can consume them directly.
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
          The derivation for your ${link "mkHaskellProject.<in>.readTheDocs"} site.
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
          - `cabalProject` the original project coming from `haskell.nix`'s `.projectCross.<name>`
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


  mkHaskellProject-IN = l.mkOption {
    type = mkHaskellProject-IN-submodule;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkHaskellProject-OUT = l.mkOption {
    type = mkHaskellProject-OUT-submodule;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkHaskellProject = l.mkOption {
    description = ''
      The `lib.iogx.mkHaskellProject` function builds your `haskell.nix`-based project.

      In this document:
        - Options for the input attrset are prefixed by `mkHaskellProject.<in>`.
        - The returned attrset contains the attributes prefixed by `mkHaskellProject.<out>`.
    '';
    type = utils.mkApiFuncOptionType mkHaskellProject-IN.type mkHaskellProject-OUT.type;
    example = l.literalExpression ''
      # nix/project.nix 
      { repoRoot, inputs, pkgs, lib, system }:
      lib.iogx.mkHaskellProject {

        shellArgs = repoRoot.nix.make-shell;

        readTheDocs = {
          enable = true;
          siteFolder = "doc/read-the-docs-site";
        };
        
        combinedHaddock.enable = true;
        
        cabalProject = pkgs.haskell-nix.cabalProject' {
          compiler-nix-name = "ghc8107";

          flake.variants.FOO = {
            compiler-nix-name = "ghc927";
          };
        };
      }

      # outputs.nix
      { repoRoot, inputs, pkgs, lib, system }:
      let 
        project = repoRoot.nix.project;
      in 
      [
        {
          inherit (project) cabalProject;
        }
        (
          project.flake
        )
        {
          hydraJobs.FOO = project.variants.FOO.hydraJobs;
        }
      ]
    '';
  };

in

{
  inherit mkHaskellProject;
  "mkHaskellProject.<in>" = mkHaskellProject-IN;
}
