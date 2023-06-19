{ inputs, inputs', iogx-config, pkgs, l, src, ... }:

let

  mkHaskellProject = meta@{ haskellCompiler, enableCross, enableHaddock, enableProfiling }: 
    let
      project-parts = import iogx-config.haskellProjectFile { inherit inputs inputs' pkgs meta; };

      prof-module = pkgs.lib.optional enableProfiling { enableProfiling = true; };

      cabal-project' = pkgs.haskell-nix.cabalProject' (_: {
        compiler-nix-name = haskellCompiler;
        src = iogx-config.repoRoot;
        shell.withHoogle = project-parts.shellWithHoogle;
        inherit (project-parts) cabalProjectLocal sha256map;
        inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP; };
        modules = [(_: { inherit (project-parts) packages; })] ++ prof-module;
      });

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
      "${ghc}-mingwW64" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = false; 
        enableCross = true; 
        enableHaddock = false;
      };
      "${ghc}-mingwW64-profiled" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = true; 
        enableCross = true; 
        enableHaddock = false;
      };
    };

  
  enforceCrossCompileOnLinux = projects:
    if !pkgs.stdenv.hostPlatform.isLinux then
      l.filterAttrs (name: _: !l.hasInfix "-mingwW64" name) projects
    else
      projects; 
  

  all-haskell-projects = 
    let 
      all-projects = l.recursiveUpdateMany (map mkHaskellProjectsForGhc iogx-config.haskellCompilers);

      final-projects = enforceCrossCompileOnLinux all-projects;
    in 
      final-projects;

in

  all-haskell-projects