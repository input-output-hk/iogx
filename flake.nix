{
  description = "Development Environemnt for IOG Projects";

  inputs = {
    devenv.url = "github:cachix/devenv";

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages/4a9d10b2ecc88a5df933e54a150339e5a97319e2";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils/b543720b25df6ffdfcf9227afafc5b8c1fabfae8";

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix/a6825537df7c0834a4410f652b6659e07ec5bde3";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs-2211";

    hackage = {
      # url = "github:input-output-hk/hackage.nix/7a4c7ed70e382aaa8fd65cc2af57bdf920320ddc";
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    iohk-nix = {
      url = "github:input-output-hk/iohk-nix/3b90a1bd7472eb39fd4eba83832310718df58dc4";
      flake = false;
    };

    sphinxcontrib-haddock = {
      url = "github:michaelpj/sphinxcontrib-haddock/f3956b3256962b2d27d5a4e96edb7951acf5de34";
      flake = false;
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix/ab608394886fb04b8a5df3cb0bab2598400e3634";

    haskell-language-server-1_9_0_0 = {
      url = "github:haskell/haskell-language-server/1916b5782d9f3204d25a1d8f94da4cfd83ae2607";
      flake = false;
    };

    haskell-language-server-1_3_0_0 = {
      url = "github:haskell/haskell-language-server/e7c5e90b6df5dff2760d76169eddaea3bdd6a831";
      flake = false;
    };

    cardano-world.url = "github:input-output-hk/cardano-world/d22f50fc77d23e2612ca2b313a098dd0b48834d4";

    nosys.url = "github:divnix/nosys/feade0141487801c71ff55623b421ed535dbdefa";

    std.url = "github:divnix/std/97348aa1056414f1c97caa7e1a4c21efda3f24e5";

    bitte-cells.url = "github:input-output-hk/bitte-cells/6f5d607b76d15238ae6729ebef8ff3fe6c0049d8";

    tullia.url = "github:input-output-hk/tullia/e1e9fb1648174b802976f6499a50fbc9c486b234";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    marlowe-cardano.url = "github:input-output-hk/marlowe-cardano";
    antaeus.url = "github:input-output-hk/antaeus";
  };

  outputs = inputs:
    let
      iogx = import ./src/bootstrap/main.nix { inherit inputs; };

      inherit (iogx) mkFlake l;

      mkRepo = name:
        let
          inputs-override = {
            marlowe-cardano = { };
            antaeus = { };
            marconi = {
              haskell-nix = inputs.marconi-haskell-nix;
              hackage = inputs.marconi-hackage;
            };
          };
          iogx-inputs = inputs // inputs-override.${name};
        in
        import (./sc-repos + "/${name}/mkFlake.nix") { inherit iogx-inputs; };

      marlowe-cardano = mkRepo "marlowe-cardano";
      antaeus = mkRepo "antaeus";
      # marconi = mkRepo "marconi";

      mkOutputs = group: l.recursiveUpdateMany [
        (l.nestAttrs marlowe-cardano.${group} [ "marlowe-cardano" ])
        (l.nestAttrs antaeus.${group} [ "antaeus" ])
        # (l.nestAttrs marconi.${group} [ "marconi" ])
      ];
    in
    {
      inherit mkFlake l;
      inherit antaeus marlowe-cardano;

      hydraJobs = mkOutputs "hydraJobs";
      devShells = mkOutputs "devShells";
      packages = mkOutputs "packages";
      apps = mkOutputs "apps";
      checks = mkOutputs "checks";

      templates.default = {
        path = ./template;
        description = "IOGX - Standard flake for IOG projects";
        welcomeText = ''
          # IOGX - Standard flake for IOG projects
          Open ./flake.nix to get started.
        '';
      };
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




# Smart Contracts Repos for Testing 

# marlowe-cardano.url = "github:input-output-hk/marlowe-cardano";

# marconi.url = "github:input-output-hk/marconi/7a160bc44448497734c11512c595b43dae8b1977";
# marconi-haskell-nix = {
#   url = "github:input-output-hk/haskell.nix/3473e3c9955954a548f28c97d5d47115c5b17b53";
#   inputs.hackage.follows = "marconi-hackage";
# };
# marconi-hackage = {
#   url = "github:input-output-hk/hackage.nix/1ea938efb94c8d7ad4f6933efffaccd0fbc47cda";
#   flake = false;
# };
