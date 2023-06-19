{ iogx-inputs }:

let

  l = import ./l.nix { inherit iogx-inputs; };


  modularise = import ./modularise.nix { inherit l; };


  libnixschema = import ./libnixschema.nix { inherit l; };


  mkFlake = user-inputs: repo-root:
    let
      iogx-config-schema = import ./iogx-config-schema.nix { inherit libnixschema; };

      # TODO check file exist and return better error message
      # TODO fix infinite recursion problem using user-inputs.self
      unvalidated-iogx-config = import (repo-root + "/nix/iogx-config.nix");

      iogx-config = libnixschema.validateConfig iogx-config-schema unvalidated-iogx-config;

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
        if iogx-config.topLevelOutputsFile != null then 
          import iogx-config.topLevelOutputsFile { inputs' = merged-inputs; }
        else 
          {};

      # TODO check collisions 
      final-outputs = top-level-outputs // systemized-outputs;
    in  
      final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake; };


  out = { inherit lib; };

in

  out 

