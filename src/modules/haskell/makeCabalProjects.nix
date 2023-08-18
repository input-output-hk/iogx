{ src, iogx-inputs, repoRoot, iogxRepoRoot, iogx-interface, user-repo-root, inputs, inputs', pkgs, l, system, ... }:

# NOTE we assume that ./nix/cabal-project.nix exists 

let
  haskell = iogx-interface."haskell.nix".load {
    inherit iogxRepoRoot repoRoot inputs inputs' pkgs system;
    lib = l;
  };

  haskellLib = pkgs.haskell-nix.haskellLib;

  # We want to pass the `pkgs` provided by `chaskell-nix:cabalProject'` to 
  # `load-haskell-project`, and not the top-level one coming from us.
  # Otherwise, if using the top-level `pkgs`, for some reason, cross-compilation 
  # is not detected:
  #   pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform ==> ALWAYS FALSE
  # haskell.nix must be doing something behind the scenes.
  # This makes things a little messy because we need to evaluate 
  # cabal-project.nix twice in each call to makeCabalProjectWith, the second 
  # time just to obtain the `overlays` though. 
  # This is fine and quick so long as the `overlays` do not use `config` nor 
  # `lib` nor depend on cross-compilation (indeed the pass our "broken" `pkgs` 
  # to the second call of import ./nix/cabal-project.nix).
  # FIXME this can be improved but there are tradeoffs:
  # 1. Expose the `{ pkgs, config, lib, ... }` only to the `modules`, but deal with two `pkgs`.
  # 2. Remove `overlays` option
  makeCabalProjectWith = meta@{ haskellCompiler, enableHaddock, enableProfiling, enableCross }:
    let
      cabal-project = pkgs.haskell-nix.cabalProject' (args@{ pkgs, ... }:
        let
          project-parts = iogx-interface."cabal-project.nix".load {
            inherit iogxRepoRoot repoRoot inputs inputs' meta system;
            inherit (args) pkgs config;
            lib = l;
          };
          prof-modules = l.optional enableProfiling { enableProfiling = true; };
        in
        {
          compiler-nix-name = haskellCompiler;
          src = user-repo-root + "/${haskell.cabalProjectFolder}";
          shell.withHoogle = project-parts.shellWithHoogle;
          inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = iogx-inputs.CHaP; };
          modules = project-parts.modules ++ prof-modules;
          inherit (project-parts) cabalProjectLocal sha256map;
        }
      );

      cabal-project' =
        let
          project-parts = iogx-interface."cabal-project.nix".load {
            inherit iogxRepoRoot repoRoot inputs inputs' pkgs meta system;
            lib = l;
            config = { };
          };
        in
        cabal-project.appendOverlays project-parts.overlays;

      cabal-project'' =
        if enableCross then
          cabal-project'.projectCross.mingwW64
        else
          cabal-project';

    in
    cabal-project'' // { inherit meta; };


  cabal-projects =
    let
      mkUnprofiled = ghc:
        l.nameValuePair ghc (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = false;
          enableHaddock = false;
          enableCross = false;
        });

      mkProfiled = ghc:
        l.nameValuePair "${ghc}-profiled" (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = true;
          enableHaddock = false;
          enableCross = false;
        });

      mkXCompiled = ghc:
        l.nameValuePair "${ghc}-mingw64" (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = false;
          enableHaddock = false;
          enableCross = true;
        });

      mkHaddocked = ghc:
        l.nameValuePair "${ghc}-haddock" (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = false;
          enableHaddock = true;
          enableCross = false;
        });

      should-cross-compile =
        haskell.enableCrossCompilation && pkgs.stdenv.system == "x86_64-linux";

    in
    rec {
      unprofiled = l.listToAttrs (map mkUnprofiled haskell.supportedCompilers);

      profiled = l.listToAttrs (map mkProfiled haskell.supportedCompilers);

      haddocked = l.listToAttrs (map mkHaddocked haskell.supportedCompilers);

      xcompiled =
        let attrs = l.listToAttrs (map mkXCompiled haskell.supportedCompilers);
        in l.optionalAttrs should-cross-compile attrs;

      profiled-and-unprofiled = profiled // unprofiled;

      unprofiled-and-xcompiled = unprofiled // xcompiled;

      unprofiled-and-default = unprofiled // { inherit default; };

      all = profiled-and-unprofiled // xcompiled // haddocked;

      default = unprofiled.${default-prefix};

      default-haddocked = haddocked."${haskell.defaultCompiler}-haddock";

      default-prefix = "${haskell.defaultCompiler}";

      profiled-prefix = "${haskell.defaultCompiler}-profiled";

      count = l.length haskell.supportedCompilers;
    };

in

cabal-projects 

