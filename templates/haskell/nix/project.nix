{ repoRoot, inputs, pkgs, lib, system }:

let

  cabalProject = pkgs.haskell-nix.cabalProject' ({ pkgs, config, ... }: 
    # Notice that the `pkgs` has been ellipsed (...) on line 1 of this file.
    let 
      # When `isCross` is `true`, it means that we are cross-compiling the project.
      # NOTE: YOU MUST USE THE `pkgs` ABOVE INSIDE THE BODY OF cabalProject'.
      isCross = pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform;
    in 
    {
      src = ../.;

      # shell.withHoogle = false;

      inputMap = {
        "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.iogx.inputs.CHaP;
      };

      name = "my-project";

      compiler-nix-name = lib.mkDefault "ghc8107";

      # flake.variants.profiled = {
      #   modules = [{ 
      #     enableProfiling = true; 
      #     enableLibraryProfiling = true; 
      #   }];
      # };

      # flake.variants.ghc928 = {
      #   compiler-nix-name = "ghc928";
      # };

      # flake.variants.ghc964 = {
      #   compiler-nix-name = "ghc964";
      # };

      modules =
        [
          {
            packages = { };
          }
          {
            packages = { };
          }
        ];
    });


    cabalProject = cabalProject'.appendOverlays [ ];


    project = lib.iogx.mkHaskellProject {
      inherit cabalProject;
      
      shellArgs = repoRoot.nix.shell;

      # includeMingwW64HydraJobs = false; 

      # readTheDocs = {
      #   enable = false;
      #   siteFolder = "doc/read-the-docs-site";
      #   sphinxToolchain = null;
      # };

      # combinedHaddock = {
      #   enable = false;
      #   prologue = "";
      #   packages = [];
      # };
    };

in

project
