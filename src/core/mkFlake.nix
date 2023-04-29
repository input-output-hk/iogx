{ inputs, systemized-inputs, flakeopts, pkgs, l, iogx, ... }:

let

  # marlowe:runtime-web:lib:server ->
  #   ghc8107-marlowe-runtime-web-lib-server-profiled
  #   ghc8107-marlowe-runtime-web-lib-server
  #   ghc8107-mingwW64-marlowe-runtime-web-lib-server-profiled
  #   ghc8107-mingwW64-marlowe-runtime-web-lib-server
  prefixFlake = { flake, ghc, cross, profiled }:
    let
      replaceCons = l.replaceStrings [ ":" ] [ "-" ];

      prefixName = name:
        let
          cross' = l.optionalString cross "-mingwW64";
          name' = "-${replaceCons name}";
          profiled' = l.optionalString profiled "-profiled";
        in
        l.nameValuePair "${ghc}${cross'}${name'}${profiled'}";

      prefixGroup = group: attrs:
        if group == "hydraJobs" then
          l.mapAttrs prefixGroup attrs
        else if group == "roots" || group == "plan-nix" || group == "coverage" then
          attrs
        else
          l.mapAttrs' prefixName attrs;
    in
    l.mapAttrs prefixGroup flake;


  mkFlakeFor = { ghc, cross, profiled, haddock }:
    let
      project' = flakeopts.haskell.project {
        inherit inputs systemized-inputs flakeopts pkgs ghc;
        enableProfiling = profiled;
        deferPluginErrors = haddock;
      };

      project = if cross then project'.projectCross.mingwW64 else project';

      flake = pkgs.haskell-nix.haskellLib.mkFlake project {
        devShell = iogx.core.devenvShell {
          inherit ghc;
          flake = final-flake; # TODO note the rec, use merged-flakes instead? 
          shell = project.shellFor { withHoogle = false; };
        };
      };

      flake' = prefixFlake { inherit ghc cross profiled flake; };

      flake'' = flake' // rec {
        ciJobs = hydraJobs;
        hydraJobs = iogx.core.hydraJobs {
          hydraJobs = flake'.hydraJobs;
        };
      };
    in
    flake'';


  mkFlakeForCompiler = ghc:
    let
      unprofiled-flake =
        mkFlakeFor { ghc = ghc; profiled = false; cross = false; haddock = false; };

      profiled-flake =
        mkFlakeFor { ghc = ghc; profiled = true; cross = false; haddock = false; };

      cross-unprofiled-flake =
        mkFlakeFor { ghc = ghc; profiled = false; cross = true; haddock = false; };

      cross-profiled-flake =
        mkFlakeFor { ghc = ghc; profiled = true; cross = true; haddock = false; };

      native-flakes = [ unprofiled-flake profiled-flake ];

      should-cross-compile = flakeopts.haskell.crossSystem == pkgs.stdenv.system;

      cross-flakes = [ cross-unprofiled-flake cross-profiled-flake ];

      all-flakes = native-flakes ++ l.optionals should-cross-compile cross-flakes;

      final-flake = l.recursiveUpdateMany all-flakes;
    in
    final-flake;


  merged-flake =
    let
      all-flakes = map mkFlakeForCompiler flakeopts.haskell.compilers;

      final-flake = l.recursiveUpdateMany all-flakes;

      default-devshell = {
        devShells.default = final-flake.devShells."${flakeopts.haskell.defaultCompiler}-default";
      };
    in
    l.recursiveUpdate final-flake default-devshell;


  user-flake = flakeopts.perSystemOutputs
    { inherit inputs systemized-inputs flakeopts pkgs; };

  final-flake = l.recursiveUpdate merged-flake user-flake;

in
final-flake
