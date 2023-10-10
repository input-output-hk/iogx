{
  description = "Flake Template for Haskell Projects at IOG";


  inputs = {

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs-2305";

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
    in
    mkFlake rec {
      inherit inputs;

      repoRoot = ./.;

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];

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

      outputs = { repoRoot, pkgs, lib, ... }: [{

        _repoRoot = repoRoot;

        packages.render-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference;

        hydraJobs.required = lib.iogx.mkHydraRequiredJob {};
        hydraJobs.render-iogx-api-reference = repoRoot.src.core.mkRenderedIogxApiReference; 

        devShells.default = lib.iogx.mkShell {
          name = "iogx";
          packages = [ pkgs.github-cli pkgs.python39 ];
          scripts.render-iogx-api-reference = {
            group = "iogx";
            description = "Produce ./doc/options.md";
            exec = ''
              set -e
              nix build .#render-iogx-api-reference --system x86_64-darwin --show-trace
              cp result doc/api.md
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
