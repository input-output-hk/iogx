{ inputs, inputs', iogx-config, iogx-interface, pkgs, l, src, user-repo-root, ... }:

let

  mkHaskellProject = meta@{ haskellCompiler, enableCross, enableHaddock, enableProfiling }: 
    let
      project-parts = iogx-interface.load-haskell-project { inherit inputs inputs' pkgs meta; };

      prof-module = pkgs.lib.optional enableProfiling { enableProfiling = true; };

      cabal-project'' = pkgs.haskell-nix.cabalProject' (_: {
        compiler-nix-name = haskellCompiler;
        src = user-repo-root;
        shell.withHoogle = project-parts.shellWithHoogle;
        inherit (project-parts) cabalProjectLocal sha256map;
        inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP; };
        modules = project-parts.modules ++ prof-module;
      });

      cabal-project' = cabal-project''.appendOverlays project-parts.overlays;

      cabal-project = if enableCross then cabal-project'.projectCross.mingwW64 else cabal-project';

      augmented-project = cabal-project // { inherit meta; };
    in 
    augmented-project;


  # TODO add enableHaddock to matrix
  mkHaskellProjectsForGhc = ghc:
    {
      "${ghc}" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = false; 
        enableCross = false; 
        enableHaddock = false;
      };
      "${ghc}-profiled" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = true; 
        enableCross = false; 
        enableHaddock = false;
      };
      "${ghc}-xwindows" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = false; 
        enableCross = true; 
        enableHaddock = false;
      };
    };

  
  filterCrossCompile = projects:
    if pkgs.stdenv.system != "x86_64-linux" || !iogx-config.shouldCrossCompile then
      l.filterAttrs (name: _: !l.hasInfix "xwindows" name) projects
    else
      projects; 
  

  all-haskell-projects = 
    let 
      all-projects = l.recursiveUpdateMany (map mkHaskellProjectsForGhc iogx-config.haskellCompilers);

      final-projects = filterCrossCompile all-projects;
    in 
      # l.trace (l.valueToString (l.attrNames final-projects)) final-projects;
      final-projects;

in

  all-haskell-projects