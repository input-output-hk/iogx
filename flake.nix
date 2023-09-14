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
    mkFlake {
      inherit inputs;

      repoRoot = ./.;

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];

      flake.templates.default = {
        path = ./template;
        description = "Flake Template for Haskell Projects at IOG";
        welcomeText = ''
          # Flake Template for Haskell Projects at IOG
          Open flake.nix to get started.
        '';
      };

      flake.lib = {
        inherit mkFlake;
        utils = import ./src/boot/utils.nix inputs;
        modularise = import ./src/boot/modularise.nix inputs;
        options = import ./src/boot/options.nix inputs;
      };

      outputs = { pkgs, lib, ... }: [{

        packages.options-doc = pkgs.nixosOptionsDoc {
          options = (
            lib.evalModules {
              modules = [{
                options = inputs.self.lib.options;
              }];
            }
          ).options;
        };

        devShells.default = pkgs.mkShell {
          name = "iogx-devshell";
          buildInputs = [ pkgs.github-cli pkgs.python39 ];
          shellHook = ''
            export PS1="\n\[\033[1;32m\][IOGX:\w]\$\[\033[0m\] "
          '';
        };
      }];
    };


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
