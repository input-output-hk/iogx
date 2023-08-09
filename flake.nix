{
  description = "Flake Template for Haskell Projects at IOG";


  inputs = {

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs-2305";

    hackage = {
      url = "github:input-output-hk/hackage.nix";
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

    haskell-language-server-1_9_0_0 = {
      # This revision is the newest working 1.9.0.0 available.
      url = "github:haskell/haskell-language-server/1916b5782d9f3204d25a1d8f94da4cfd83ae2607";
      flake = false;
    };

    haskell-language-server-1_8_0_0 = {
      # This revision is the newest 1.8.0.0 which includes a patch for the stan plugin.
      url = "github:haskell/haskell-language-server/855a88238279b795634fa6144a4c0e8acc7e9644";
      flake = false;
    };

    easy-purescript-nix = {
      url = "github:justinwoo/easy-purescript-nix";
      flake = false;
    };
  };


  outputs = iogx-inputs:
    let
      iogx = import ./src/iogx { inherit iogx-inputs; };
    in
    iogx.lib.mkFlake {
      inputs = iogx-inputs;
      systems = [ "x86_64-darwin" "x86_64-linux" ];
      repoRoot = ./.;
      config = {
        formatters = {
          nixpkgs-fmt.enable = true;
        };
        shell = { pkgs, ... }: {
          name = "iogx";
          packages = [
            pkgs.github-cli
          ];
        };
        per-system-outputs = { pkgs, ... }: rec {
          packages.testsuite = import ./tests { inherit iogx pkgs; };
        };
        top-level-outputs = {
          inherit (iogx) lib;
          template.default = {
            path = ./template;
            description = "Flake Template for Haskell Projects at IOG";
            welcomeText = ''
              # Flake Template for Haskell Projects at IOG
              Open flake.nix to get started.
            '';
          };
        };
      };
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
