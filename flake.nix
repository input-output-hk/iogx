{
  description = "Flake Templates for Projects at IOG";


  inputs = {

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs";

    # We use this to replace broken packages in haskell-nix/nixpkgs.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/b81af66deb21f73a70c67e5ea189568af53b1e8c";

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    iohk-nix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sphinxcontrib-haddock = {
      url = "github:michaelpj/sphinxcontrib-haddock";
      flake = false;
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    easy-purescript-nix = {
      url = "github:justinwoo/easy-purescript-nix";
      flake = true;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix2container.url = "github:nlewo/nix2container";

    # By referencing our templates as flake inputs, we can write tests for them.
    iogx-template-vanilla.url = "github:input-output-hk/iogx?dir=templates/vanilla";
    iogx-template-haskell.url = "github:input-output-hk/iogx?dir=templates/haskell";

    plutus-tx-template.url = "github:input-output-hk/iogx?dir=plutus-tx-template";
  };


  outputs = inputs:
    let
      mkFlake = import ./src/mkFlake.nix inputs;

      mkTestShell = lib: ghc: lib.iogx.mkShell {
        tools.haskellCompilerVersion = ghc;
        preCommit = {
          cabal-fmt.enable = true;
          stylish-haskell.enable = true;
          fourmolu.enable = true;
          hlint.enable = true;
          shellcheck.enable = true;
          prettier.enable = true;
          editorconfig-checker.enable = true;
          nixpkgs-fmt.enable = true;
          optipng.enable = true;
          purs-tidy.enable = true;
          custom-hook = {
            enable = true;
            entry = "echo 'Running custom hook' ; exit 1";
            pass_filenames = false;
            language = "fail";
          };
        };
      };
    in

    mkFlake rec {
      inherit inputs;

      repoRoot = ./.;

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      flake.templates.default = flake.templates.vanilla;

      flake.templates.haskell = {
        path = ./templates/haskell;
        description = "Flake Template for Haskell Projects";
        welcomeText = ''
          # Flake Template for Haskell Projects
          Edit your cabal.project and run `nix develop` to enter the shell.
        '';
      };

      flake.templates.vanilla = {
        path = ./templates/vanilla;
        description = "Flake Template for Blank Projects";
        welcomeText = ''
          # Flake Template for Blank Projects
          Run `nix develop` to enter the shell.
        '';
      };

      flake.lib = {
        inherit mkFlake;
        utils = import ./src/lib/utils.nix inputs;
        modularise = import ./src/lib/modularise.nix inputs;
        options = import ./src/options inputs;
      };

      outputs = { repoRoot, inputs, pkgs, lib, ... }: [{

        inherit repoRoot; # For debugging 

        packages.rendered-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference;

        hydraJobs = {
          ghc810-shell = mkTestShell lib "ghc810";
          ghc92-shell = mkTestShell lib "ghc92";
          ghc96-shell = mkTestShell lib "ghc96";
          ghc98-shell = mkTestShell lib "ghc98";
          rendered-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference;
          testsuite = repoRoot.testsuite.main;
          required = lib.iogx.mkHydraRequiredJob { };
          plutus-tx-template = inputs.plutus-tx-template;
        };

        devShells.default = lib.iogx.mkShell {
          name = "iogx";
          packages = [
            pkgs.jq
            pkgs.github-cli
            pkgs.python39
            pkgs.nix-prefetch-github
          ];
          preCommit = {
            editorconfig-checker.enable = true;
            nixpkgs-fmt.enable = true;
          };
          scripts.render-iogx-api-reference = {
            group = "iogx";
            description = "Generate ./doc/api.md";
            exec = repoRoot.scripts."render-iogx-api-reference.sh";
          };
          scripts.find-repos-that-use-iogx = {
            group = "iogx";
            description = "Find repos in input-output-hk that use iogx";
            exec = repoRoot.scripts."find-repos-that-use-iogx.sh";
          };
          scripts.bump-iogx-everywhere = {
            group = "iogx";
            description = "Create or update a PR to bump iogx in various repos";
            exec = repoRoot.scripts."bump-iogx-everywhere.sh";
          };
        };
      }];
    };


  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
    allow-import-from-derivation = true;
  };
}
