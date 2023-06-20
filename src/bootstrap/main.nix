{ iogx-inputs }:

let

  l = import ../lib/l.nix { inherit iogx-inputs; };


  modularise = import ../lib/modularise.nix { inherit l; };


  libnixschema = import ../lib/libnixschema.nix { inherit l; };

  
  iogx-schemas = {

    haskell-project = import ../schema/haskell-project.nix { inherit libnixschema l; };

    hydra-jobs = import ../schema/hydra-jobs.nix { inherit libnixschema l; };

    iogx-config = import ../schema/iogx-config.nix { inherit libnixschema l; };

    pre-commit-check = import ../schema/pre-commit-check.nix { inherit libnixschema l; };

    shell = import ../schema/shell.nix { inherit libnixschema l; };
  };


  mkFlake = user-inputs: repo-root:
    let 
      # TODO fix infinite recursion problem using user-inputs.self
      unvalidated-iogx-config = libnixschema.demandFile "${repo-root}/nix/iogx-config.nix" ''
        IOGX: Please create the file ./nix/iogx-config.nix in the repository.
        DOCS: http://www.github.com/input-output-hk/iogx/README.md#iogx-config
      '';

      iogx-config = 
        let result = libnixschema.validateConfig iogx-schemas.iogx-config unvalidated-iogx-config; in 
        if result.status == "success" then result.config else l.throw ''
          IOGX: Your ./nix/iogx-config.nix has errors:
          ${l.valueToString result.errors}
        '';

      merged-inputs = import ./merge-inputs.nix { inherit iogx-inputs user-inputs iogx-config l; };

      systemized-outputs = iogx-inputs.flake-utils.lib.eachSystem iogx-config.systems (system:
        let
          inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
          inputs' = merged-inputs;
          pkgs = import ./pkgs.nix { inherit iogx-inputs system; };
          root = ../.;
          module = "src";
          args = { inherit inputs inputs' pkgs iogx-config l; };
          src = modularise { inherit root module args; };
        in
        src.core.flake
      );

      top-level-outputs = 
        l.importFileWithDefault {} "${repo-root}/nix/top-level-outputs.nix" { inputs' = merged-inputs; };

      # TODO check collisions 
      final-outputs = top-level-outputs // systemized-outputs;
    in  
      final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake iogx-schemas; };


  out = { inherit lib; };

in

  out 

