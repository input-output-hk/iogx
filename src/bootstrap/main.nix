{ iogx-inputs }:

let

  l = import ../lib/l.nix { inherit iogx-inputs; };


  modularise = import ../lib/modularise.nix { inherit l; };


  libnixschema = import ../lib/libnixschema.nix { inherit l; };

  
  iogx-schemas = import ../schemas { inherit libnixschema l; };


  loadInterfaceFile = repo-root: file-name: args:
    let 
      config' = l.importFileWithDefault {} "${repo-root}/nix/${file-name}.nix";
      config = if args == null then config' else config' args;
      schema = import (../schemas + "/${file-name}.nix") { inherit libnixschema l; };
      value = libnixschema.validateConfig schema config ''
        IOGX: Your ./nix/${file-name}.nix has errors
        DOCS: http://www.github.com/input-output-hk/iogx/README.md#iogx-config
      '';
    in 
      value;


  mkFlake = user-inputs: repo-root:
    let 
      # # TODO fix infinite recursion problem using user-inputs.self
      # unvalidated-iogx-config = libnixschema.demandFile "${repo-root}/nix/iogx-config.nix" ''
      #   IOGX: Please create the file ./nix/iogx-config.nix in the repository
      #   DOCS: http://www.github.com/input-output-hk/iogx/README.md#iogx-config
      # '';

      # iogx-config = libnixschema.validateConfig iogx-schemas.iogx-config unvalidated-iogx-config ''
      #   IOGX: Your ./nix/iogx-config.nix has errors
      #   DOCS: http://www.github.com/input-output-hk/iogx/README.md#iogx-config
      # '';

      iogx-config = loadInterfaceFile repo-root "iogx-config" null; 

      # interface-files = {
      #   read-top-level-outputs = l.importFileWithDefault {} "${repo-root}/nix/top-level-outputs.nix";
      #   read-haskell-project = l.importFileWithDefault {} "${repo-root}/nix/haskell-project.nix";
      #   read-hydra-jobs = l.importFileWithDefault {} "${repo-root}/nix/hydra-jobs.nix";
      #   read-pre-commit-check = l.importFileWithDefault {} "${repo-root}/nix/pre-commit-check.nix";
      #   read-shell = l.importFileWithDefault {} "${repo-root}/nix/shell.nix";
      #   read-per-system-outputs = l.importFileWithDefault {} "${repo-root}/nix/per-system-outputs.nix";
      # };
      
      merged-inputs = import ./merge-inputs.nix { inherit iogx-inputs user-inputs iogx-config l; };

      systemized-outputs = iogx-inputs.flake-utils.lib.eachSystem iogx-config.systems (system:
        let
          inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
          inputs' = merged-inputs;
          pkgs = import ./pkgs.nix { inherit iogx-inputs system; };
          root = ../.;
          module = "src";
          args = { inherit inputs inputs' pkgs iogx-config l loadInterfaceFile; };
          src = modularise { inherit root module args; };
        in
        src.core.flake
      );

      top-level-outputs = loadInterfaceFile repo-root "top-level-outputs" { inputs' = merged-inputs; };

      # TODO check collisions 
      final-outputs = top-level-outputs // systemized-outputs;
    in  
      final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake iogx-schemas; };


  out = { inherit lib; };

in

  out 

