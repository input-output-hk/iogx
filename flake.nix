{
  description = "Development Environemnt for IOG Projects";

  inputs = {

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix/56a471cfce2c61031e193bdef527bbd6e646454e"; # 3 May 2023
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs-2211";

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    iohk-nix = {
      url = "github:input-output-hk/iohk-nix";
      flake = false;
    };

    sphinxcontrib-haddock = {
      url = "github:michaelpj/sphinxcontrib-haddock";
      flake = false;
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    haskell-language-server-1_9_0_0 = {
      url = "github:haskell/haskell-language-server/1916b5782d9f3204d25a1d8f94da4cfd83ae2607";
      flake = false;
    };

    haskell-language-server-1_8_0_0 = {
      url = "github:haskell/haskell-language-server/855a88238279b795634fa6144a4c0e8acc7e9644";
      flake = false;
    };

    nosys.url = "github:divnix/nosys";
  };

  outputs = iogx-inputs:
    let
      iogx = import ./src/bootstrap/main.nix { inherit iogx-inputs; };

      template = {
        path = ./template;
        description = "IOGX - Standard flake for IOG projects";
        welcomeText = ''
          # IOGX - Standard flake for IOG projects
          Open ./flake.nix to get started.
        '';
      };

      global-outputs = {
        inherit (iogx) mkFlake l modularise flakeopts-schema libnixschema;
        templates.default = template;
      };

      per-system-outputs = iogx-inputs.flake-utils.lib.eachDefaultSystem (system:
        { 
          checks.flakeopts-schema-tests = import ./tests/flakeopts-schema-tests.nix { 
            inherit iogx;
            pkgs = iogx-inputs.nixpkgs.legacyPackages.${system};  
          };
        }
      );
    in
     global-outputs // per-system-outputs;


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
