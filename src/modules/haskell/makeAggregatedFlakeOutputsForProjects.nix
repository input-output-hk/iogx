{ src, iogx-inputs, iogx-interface, inputs, inputs', pkgs, l, ... }:

projects: # The haskell.nix projects with the meta field, prefixed by ghc config

let
  haskell = iogx-interface."haskell.nix".load { inherit inputs inputs' pkgs; };

  haskellLib = pkgs.haskell-nix.haskellLib;


  # :: haskell.nix-project(with meta field) -> flake-outputs
  makeFlakeOutputsForProject = project:
    let
      flake = haskellLib.mkFlake project { };

      meta = project.meta;

      is-single-ghc = l.length haskell.supportedCompilers < 2;

      renameGroup = group:
        let mkPair = name: l.nameValuePair (renameComponent name);
        in l.mapAttrs' mkPair group;

      renameComponent = name:
        let
          replaceCons = l.replaceStrings [ ":" ] [ "-" ];
          ghc = if is-single-ghc then "" else "-${meta.haskellCompiler}";
          name' = replaceCons name;
          profiled' = l.optionalString meta.enableProfiling "-profiled";
        in
        "${name'}${ghc}${profiled'}";

      renameGroupShort = group:
        let mkPair = name: l.nameValuePair (renameComponentShort name);
        in l.mapAttrs' mkPair group;

      renameComponentShort = name:
        let
          ghc = if is-single-ghc then "" else "-${meta.haskellCompiler}";
          name' = l.last (l.splitString ":" name);
          profiled' = l.optionalString meta.enableProfiling "-profiled";
        in
        "${name'}${ghc}${profiled'}";

      packages = {
        haskell-nix-project-roots = flake.hydraJobs.roots;
        haskell-nix-project-plan-nix = flake.hydraJobs.plan-nix;
        # haskell-nix-project-coverage = flake.hydraJobs.coverage;
      } // flake.packages;

      outputs = {
        apps = renameGroup flake.apps // renameGroupShort flake.apps;
        checks = renameGroup flake.checks // renameGroupShort flake.checks;
        packages = renameGroup packages // renameGroupShort packages;
      };
    in
    outputs;


  outputs =
    let projects-list = l.attrValues projects; # TODO optimize, remove "default" and reuse result
    in l.recursiveUpdateMany (map makeFlakeOutputsForProject projects-list);

in

outputs
