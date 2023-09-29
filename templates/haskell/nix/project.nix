{ repoRoot, inputs, lib, system }:

let

  haskellDotNixProject = pkgs.haskell-nix.cabalProject' ({ pkgs, config, ... }: {

    src = ../.;

    # shell.withHoogle = false;

    inputMap = {
      "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
    };

    name = "my-project";

    compiler-nix-name = lib.mkDefault "ghc8107";

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
        {
          packages = { };
        }
        {
          packages = { };
        }
      ];
  });


  haskellDotNixProject = haskellDotNixProject'.appendOverlays [ ];


  project = lib.iogx.mkHaskellProject {
    inherit haskellDotNixProject;
    
    shellArgs = repoRoot.nix.shell;

    # enableCrossCompileMingwW64 = false; 

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
