{ src, iogx-inputs, iogx-interface, user-repo-root, inputs, inputs', pkgs, l, ... }:

# NOTE we assume that ./nix/cabal-project.nix exists 

let
  haskell = iogx-interface."haskell.nix".load { inherit inputs inputs' pkgs; };

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
  makeCabalProjectWith = meta@{ haskellCompiler, enableHaddock, enableProfiling }:
    let
      cabal-project = pkgs.haskell-nix.cabalProject' (args@{ pkgs, ... }:
        let
          # If makeCabalProjectWith has been called then we assume that 
          # ./nix/cabal-project.nix exists.
          project-parts = iogx-interface."cabal-project.nix".load {
            inherit meta;
            inherit (args) pkgs config lib;
            inherit inputs inputs';
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
            config = { };
            inherit meta pkgs;
            inherit (pkgs) lib;
            inherit inputs inputs';
          };
        in
        cabal-project.appendOverlays project-parts.overlays;
    in
    cabal-project' // { inherit meta; };


  cabal-projects =
    let
      mkNormal = ghc:
        l.nameValuePair ghc (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = false;
          enableHaddock = false;
        });

      mkProfiled = ghc:
        l.nameValuePair "${ghc}-profiled" (makeCabalProjectWith {
          haskellCompiler = ghc;
          enableProfiling = true;
          enableHaddock = false;
        });

      prefixed-normals = map mkNormal haskell.supportedCompilers;
      prefixed-profiled = map mkProfiled haskell.supportedCompilers;
      prefixed = l.listToAttrs (prefixed-normals ++ prefixed-profiled);
      default = prefixed.${haskell.defaultCompiler};
      profiled = prefixed."${haskell.defaultCompiler}-profiled";
    in
    prefixed // { inherit default profiled; };

in

cabal-projects 

