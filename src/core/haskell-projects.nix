{ inputs, inputs', iogx-config, iogx-interface, pkgs, l, src, user-repo-root, ... }:

let

  # NOTE. We want to pass the `pkgs` provided by `cabalProject'` to `load-haskell-project`,
  # and not the top-level one coming from us.
  # Otherwise, if using the top-level `pkgs`, for some reason, x-compilation is not detected:
  #   pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform ==> ALWAYS FALSE
  # haskell.nix must be doing something behind the scenes.
  # This makes things a little messy because we need to evaluate haskell-project.nix twice,
  # the second time just to obtain the `overlays` though. 
  # This is fine and quick so long as the `overlays` do not use `config` nor `lib` nor depend 
  # on x-compilation (indeed the pass our "broken" `pkgs` to the second call of 
  # `load-haskell-project`).
  # FIXME this can be improved but there are tradeoffs:
  # 1. Expose the `{ pkgs, config, lib, ... }` only to the `modules`, but deal with two `pkgs`.
  # 2. Remove `overlays` option
  mkHaskellProject = meta@{ haskellCompiler, enableHaddock, enableProfiling }: 
    let
      cabal-project' = pkgs.haskell-nix.cabalProject' ({ pkgs, config, lib, ... }: 
        let 
          prof-module = pkgs.lib.optional enableProfiling { enableProfiling = true; };

          project-parts = iogx-interface.load-haskell-project { inherit inputs inputs' meta pkgs config lib; };

          project = {
            compiler-nix-name = haskellCompiler;
            src = user-repo-root;
            shell.withHoogle = project-parts.shellWithHoogle;
            inherit (project-parts) cabalProjectLocal sha256map;
            inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP; };
            modules = project-parts.modules ++ prof-module;
          };
        in 
          project
      );

      project-parts = iogx-interface.load-haskell-project 
        { inherit inputs inputs' meta pkgs; config = {}; lib = pkgs.lib; };

      cabal-project = cabal-project'.appendOverlays project-parts.overlays; 

      augmented-project = cabal-project // { inherit meta; };
    in 
    augmented-project;


  # TODO add enableHaddock to matrix
  mkHaskellProjectsForGhc = ghc:
    {
      "${ghc}" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = false; 
        enableHaddock = false;
      };
      "${ghc}-profiled" = mkHaskellProject { 
        haskellCompiler = ghc;
        enableProfiling = true; 
        enableHaddock = false;
      };
    };
  

  all-haskell-projects = 
    l.recursiveUpdateMany (map mkHaskellProjectsForGhc iogx-config.haskellCompilers);

in

  all-haskell-projects