iogx-inputs:

let

  utils = import ./lib/utils.nix iogx-inputs;
  modularise = import ./lib/modularise.nix iogx-inputs;
  options = import ./options iogx-inputs;


  mkGitRevOverlay = user-inputs: _: _: {
    # `self.rev` is only defined when the git tree is not dirty
    gitrev = user-inputs.self.rev or "0000000000000000000000000000000000000000";
  };


  # prefetch-npm-deps is broken in the current version of nixpkgs (which is 
  # nixpkgs-unstable coming from haskell.nix), so we need this hack.
  # Same for dockerTools
  # TODO when we bump haskell-nix, check if this is still needed.
  prefetch-npm-deps-overlay = prev: _:
    let
      stable-pkgs = import iogx-inputs.nixpkgs-stables { inherit (prev) system; };
    in
    {
      prefetch-npm-deps = stable-pkgs.prefetch-npm-deps;
      dockerTools = stable-pkgs.docker-tools;
    };


  mkNixpkgs = user-inputs: system: args:
    import iogx-inputs.nixpkgs {
      inherit system;
      config = iogx-inputs.haskell-nix.config // (args.config or { });
      overlays =
        [
          iogx-inputs.iohk-nix.overlays.crypto
          iogx-inputs.iohk-nix.overlays.cardano-lib
          iogx-inputs.haskell-nix.overlay
          iogx-inputs.iohk-nix.overlays.haskell-nix-crypto
          # WARNING: The order of these is crucial
          # The iohk-nix.overlays.haskell-nix-crypto depends on both the 
          # iohk-nix.overlays.crypto and the haskell-nix.overlay overlays 
          # and so must be after them in the list of overlays to nixpkgs.
          iogx-inputs.iohk-nix.overlays.haskell-nix-extra
          (mkGitRevOverlay user-inputs)
          prefetch-npm-deps-overlay
        ]
        ++ (args.overlays or [ ]);
    };


  # This creates the IOGX lib and will become available as lib.iogx.* to the user.
  mkIogxLib = desystemized-user-inputs: pkgs:
    let
      iogx = { inherit utils modularise options; };
      repoRoot = modularise {
        root = ../.;
        module = "repoRoot";
        args = {
          user-inputs = desystemized-user-inputs;
          iogx-inputs = utils.deSystemize pkgs.stdenv.system iogx-inputs;
          lib = builtins // pkgs.lib // { inherit iogx; };
          system = pkgs.stdenv.system;
          inherit pkgs;
        };
      };
    in
    {
      mkShell = repoRoot.src.core.mkShell;
      mkHaskellProject = repoRoot.src.core.mkHaskellProject;
      mkHydraRequiredJob = repoRoot.src.core.mkHydraRequiredJob;

      inherit (iogx) utils modularise options;
    };


  mkFlake = args':
    let
      evaluated-modules = iogx-inputs.nixpkgs.lib.evalModules {
        modules = [{
          options = options;
          config."mkFlake.<in>" = args';
        }];
      };

      args = evaluated-modules.config."mkFlake.<in>";

      mkPerSystemFlake = system:
        let
          user-inputs = args.inputs;

          desystemized-user-inputs = utils.deSystemize system user-inputs;

          pkgs = mkNixpkgs user-inputs system args.nixpkgsArgs;

          lib = builtins // pkgs.lib // {
            iogx = mkIogxLib desystemized-user-inputs pkgs;
          };

          modularised-user-repo-root = modularise {
            debug = args.debug;
            root = args.repoRoot;
            module = "repoRoot";
            args = {
              inputs = desystemized-user-inputs;
              inherit pkgs lib system;
            };
          };

          args-for-user-outputs = {
            repoRoot = modularised-user-repo-root;
            inputs = desystemized-user-inputs;
            inherit pkgs lib system;
          };

          evaluated-outputs =
            if lib.typeOf args.outputs == "path" then
              import args.outputs args-for-user-outputs
            else
              args.outputs args-for-user-outputs;

          flake = utils.recursiveUpdateMany (lib.concatLists [ evaluated-outputs ]);
        in
        flake;

      flake = iogx-inputs.flake-utils.lib.eachSystem args.systems mkPerSystemFlake;

      flake' = iogx-inputs.nixpkgs.lib.recursiveUpdate args.flake flake;
    in
    flake';

in

mkFlake
