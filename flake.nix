{
  description = "Flake Template for Haskell Projects at IOG";


  inputs = {

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs";

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
  };


  outputs = inputs:
    let
      mkFlake = import ./src/mkFlake.nix inputs;

      mkDevShell = lib: ghc: lib.iogx.mkShell {
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
          Open flake.nix to get started.
        '';
      };

      flake.templates.vanilla = {
        path = ./templates/vanilla;
        description = "Flake Template for Vanilla Projects";
        welcomeText = ''
          # Flake Template for Vanilla Projects
          Open flake.nix to get started.
        '';
      };

      flake.lib = {
        inherit mkFlake;
        utils = import ./src/lib/utils.nix inputs;
        modularise = import ./src/lib/modularise.nix inputs;
        options = import ./src/options inputs;
      };

      outputs = { repoRoot, inputs, pkgs, lib, ... }: [{

        inherit repoRoot;

        packages.render-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference;

        hydraJobs.devShells.ghc810 = mkDevShell lib "ghc810";
        hydraJobs.devShells.ghc92 = mkDevShell lib "ghc92";
        hydraJobs.devShells.ghc96 = mkDevShell lib "ghc96";
        hydraJobs.render-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference;
        hydraJobs.required = lib.iogx.mkHydraRequiredJob { };

        devShells.default = lib.iogx.mkShell {
          name = "iogx";
          packages = [
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
            description = "Produce ./doc/options.md";
            exec = ''
              set -e
              nix build .#render-iogx-api-reference --show-trace "$@"
              cp result doc/api.md
            '';
          };
          scripts.find-repos-that-use-iogx = {
            group = "iogx";
            description = "Find consumers of iogx in input-output-hk";
            exec = ''
              GITHUB_TOKEN=$1 
              repos=$(gh repo list input-output-hk --json name --source --limit 1000 | jq -c '.[]')
              for repo in $repos; do
                repo_name=$(echo $repo | jq -r .name)
                curl \
                  -O \
                  -s \
                  -H "\'Authorization: token $GITHUB_TOKEN\'" \
                  -H 'Accept: application/vnd.github.v3.raw' \
                  -L "https://api.github.com/repos/input-output-hk/$repo_name/contents/flake.nix"
                if cat flake.nix | grep -q "input-output-hk/iogx"; then 
                  echo "input-output-hk/$repo_name"
                fi
              done
            '';
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
