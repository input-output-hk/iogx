{ repoRoot, inputs, pkgs, lib, system }:

let 
  
  project' = lib.iogx.mkProject {

    mkShell = repoRoot.nix.shell;

    # readTheDocs = {
    #   siteFolder = null;
    # };

    # combinedHaddock = {
    #   enable = false;
    #   prologue = "";
    #   packages = [];
    # };

    cabalProjectArgs = {
      
      # src = ../.;

      # shell.withHoogle = false;

      # inputMap = {
      #   "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
      # };

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
        ({ config, ... }: { 
          packages = { };
        }) 
        ({ config, ... }: { 
          packages = { };
        }) 
        ({ config, ... }: { 
          packages = { };
        }) 
      ];
    };
  };


  project = project'.appendOverlays [];

in 

  project