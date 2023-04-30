{ inputs, systemized-inputs, flakeopts, pkgs, l, iogx, ... }:

let
  # marlowe:runtime-web:lib:server ->
  #   ghc8107-marlowe-runtime-web-lib-server-profiled
  #   ghc8107-marlowe-runtime-web-lib-server
  #   ghc8107-mingwW64-marlowe-runtime-web-lib-server-profiled
  #   ghc8107-mingwW64-marlowe-runtime-web-lib-server
  renameFlakeOutputs = { flake, ghc, cross, profiled }:
    let
      replaceCons = l.replaceStrings [ ":" ] [ "-" ];

      prefixName = name:
        let
          # is-single-compiler = l.listLength flakeopts.haskellCompilers == 1;
          # is-default-compiler = ghc == flakeopts.defaultHaskellCompiler;
          prefix = flakeopts.flakeOutputsPrefix;
          cross' = l.optionalString cross "-mingwW64";
          name' = "-${replaceCons name}";
          profiled' = l.optionalString profiled "-profiled";
        in
        l.nameValuePair "${prefix}${ghc}${cross'}${name'}${profiled'}";

      prefixGroup = group: attrs:
        if group == "hydraJobs" then
          l.mapAttrs prefixGroup attrs
        else if group == "roots" || group == "plan-nix" || group == "coverage" then
          attrs
        else
          l.mapAttrs' prefixName attrs;
    in
    l.mapAttrs prefixGroup flake;


  mkFlakeFor = { ghc, cross, profiled }:
    let
      project' = flakeopts.haskellProjectFile {
        inherit inputs systemized-inputs flakeopts pkgs ghc;
        deferPluginErrors = false;
        enableProfiling = profiled;
      };

      project = if cross then project'.projectCross.mingwW64 else project';

      flake = pkgs.haskell-nix.haskellLib.mkFlake project {
        # NOTE: we append the ghc to the shell, so that we can retrieve it 
        # later when making the devenvShell.
        devShell = project.shellFor { withHoogle = false; } // { inherit ghc; };
      };
    in
    renameFlakeOutputs { inherit ghc cross profiled flake; };


  mkFlakeForCompiler = ghc:
    let
      unprofiled-flake =
        mkFlakeFor { inherit ghc; profiled = false; cross = false; };
      profiled-flake =
        mkFlakeFor { inherit ghc; profiled = true; cross = false; };
      cross-unprofiled-flake =
        mkFlakeFor { inherit ghc; profiled = false; cross = true; };
      cross-profiled-flake =
        mkFlakeFor { inherit ghc; profiled = true; cross = true; };

      native-flakes = [ unprofiled-flake profiled-flake ];
      should-cross-compile = flakeopts.haskellCrossSystem == pkgs.stdenv.system;
      cross-flakes = [ cross-unprofiled-flake cross-profiled-flake ];
      all-flakes = native-flakes ++ l.optionals should-cross-compile cross-flakes;
    in
    l.recursiveUpdateMany all-flakes;


  # Manually add the default devShell, since all existing devShells in the 
  # flake are prefixed by the compiler name (e.g. ghc8107-default).
  addDefaultDevenvShell = flake:
    let
      ghc = "${flakeopts.defaultHaskellCompiler}-default";
      flake' = { devShells.default = flake.devShells.${ghc}; };
    in
    l.recursiveUpdate flake flake';


  addUserPerSystemOutputs = flake:
    let
      flake' = flakeopts.perSystemOutputs
        { inherit inputs systemized-inputs flakeopts pkgs; };
    in
    l.recursiveUpdate flake flake';


  addReadTheDocsPackages = flake:
    let
      flake' = rec {
        packages = iogx.readthedocs.sites;
        hydraJobs.packages = packages;
      };
    in
    if flakeopts.includeReadTheDocsSite then
      l.recursiveUpdate flake flake'
    else
      flake;


  addDevShells = flake:
    let
      mkDevShell = _: shell: iogx.core.mkDevShell.mkDevShell { inherit shell flake; };
      flake' = { devShells = l.mapAttrs mkDevShell flake.devShells; };
    in
    if flakeopts.includeDevShells then
      l.recursiveUpdate flake flake'
    else
      flake;


  addHydraJobs = flake:
    let
      flake' = rec {
        hydraJobs = iogx.core.mkHydraJobs { inherit flake; };
        ciJobs = hydraJobs;
      };
    in
    if flakeopts.includeHydraJobs then
      flake // flake'
    else
      flake;


  removeUnwantedOutputs = flake:
    let
      attrs =
        l.optionals (!flakeopts.includeHaskellApps) [ "apps" ] ++
        l.optionals (!flakeopts.includeHaskellChecks) [ "checks" ] ++
        l.optionals (!flakeopts.includeHaskellPackages) [ "packages" ] ++
        [ "devShell" ]; # We always remove the legacy devShell
    in
    removeAttrs flake attrs;


  mergeBaseFlake = flake:
    l.recursiveUpdate flakeopts.baseFlake flake;


  mkFinalFlake =
    l.composeManyLeft [
      # First we remove the unwanted stuff
      removeUnwantedOutputs
      # Then we add the user outputs
      addUserPerSystemOutputs
      # Then we add the readthedocs stuff both to packages and hydraJobs
      addReadTheDocsPackages
      # Then we add the devShells
      addDevShells
      # Must come after addDevShells
      addDefaultDevenvShell
      # We can now add the hydraJobs, since the flake is fully populated now
      addHydraJobs
      # And finally merge with the existing flake
      mergeBaseFlake
    ];


  __finalflake__ =
    let
      all-flakes = map mkFlakeForCompiler flakeopts.haskellCompilers;
      merged-flake = l.recursiveUpdateMany all-flakes;
    in
    mkFinalFlake merged-flake;

in
__finalflake__
