iogx-inputs:

let

  utils = import ./boot/utils.nix iogx-inputs;
  modularise = import ./boot/modularise.nix iogx-inputs;
  options = import ./boot/options.nix iogx-inputs;


  mkNixpkgs = system: args:
    import iogx-inputs.nixpkgs {
      inherit system;
      config = iogx-inputs.haskell-nix.config // args.config;
      overlays =
        [
          # WARNING: The order of these is crucial
          iogx-inputs.iohk-nix.overlays.crypto
          iogx-inputs.iohk-nix.overlays.cardano-lib
          iogx-inputs.haskell-nix.overlay
          iogx-inputs.iohk-nix.overlays.haskell-nix-crypto
          iogx-inputs.iohk-nix.overlays.haskell-nix-extra
        ]
        ++ args.overlays;
    };


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


  mkFlake =
    { inputs
    , repoRoot
    , systems ? [ "x86_64-linux" "x86_64-darwin" ]
    , outputs ? [ ]
    , flake ? { }
    , nixpkgsArgs ? { config = { }; overlays = [ ]; }
    , debug ? false
    , ...
    }:
    let
      flake'' = iogx-inputs.nixpkgs.lib.recursiveUpdate flake flake';

      flake' = iogx-inputs.flake-utils.lib.eachSystem systems mkPerSystemFlake;

      mkPerSystemFlake = system:
        let
          user-inputs = inputs;

          desystemized-user-inputs = utils.deSystemize system user-inputs;

          pkgs = mkNixpkgs system nixpkgsArgs;

          lib = builtins // pkgs.lib // {
            iogx = mkIogxLib desystemized-user-inputs pkgs;
          };

          modularised-user-repo-root = modularise {
            inherit debug;
            root = repoRoot;
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

          throwInvalidOutputTypeError = i: mod:
            utils.throwInvalidFieldError {
              docs = "mkFlake:outputs";
              message = ''
                Value at index ${i} has invalid type:
                  ${lib.typeOf mod}
                Values must either have type:
                  Path
                Or:
                  AttrSet 
                Or:
                  [AttrSet]
                Or:
                  { repoRoot, inputs, pkgs, system, lib, ... } -> AttrSet
                Or:
                  { repoRoot, inputs, pkgs, system, lib, ... } -> [AttrSet]
              '';
            };

          evaluateOutputs = args: mod:
            if lib.typeOf mod == "path" then
              evaluateOutputs args (import mod)
            else if lib.typeOf mod == "set" then
              [ mod ]
            else if lib.typeOf mod == "lambda" then
              evaluateOutputs args (mod args)
            else if lib.typeOf mod == "list" then
              lib.concatLists (map (evaluateOutputs args) mod)
            else
              throwInvalidOutputTypeError mod;

          evaluated-outputs = evaluateOutputs args-for-user-outputs outputs;

          flake = utils.recursiveUpdateMany evaluated-outputs;
        in
        flake;
    in
    flake'';

in

mkFlake
