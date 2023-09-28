{ repoRoot, inputs, pkgs, lib, system }:

let

  haskellDotNixProject = pkgs.haskell-nix.cabalProject' {

    src = ../.;

    # shell.withHoogle = false;

    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
    };

    name = "my-project";

    compiler-nix-name = "ghc8107";

    # flake.variants.profiled = {
    #   modules = [{ enableProfiling = true; }];
    # };

    # flake.variants.ghc928 = {
    #   compiler-nix-name = "ghc928";
    # };

    # flake.variants.ghc964 = {
    #   compiler-nix-name = "ghc964";
    # };

    modules =
      [
        ({ config, pkgs, ... }: {
          packages = { };
        })
        ({ config, pkgs, ... }: {
          packages = { };
        })
      ];
  };


  haskellDotNixProject = haskellDotNixProject'.appendOverlays [ ];


  project = lib.iogx.mkHaskellProject {
    inherit haskellDotNixProject;
    
    shellArgsForProjectVariant = repoRoot.nix.shell;

    # crossCompileMingwW64Supported = false; 

    # readTheDocs = {
    #   siteFolder = null;
    # };

    # combinedHaddock = {
    #   enable = false;
    #   prologue = "";
    #   packages = [];
    # };
  };

in

project
