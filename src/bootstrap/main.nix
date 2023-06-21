{ iogx-inputs }:

let

  l = import ../lib/l.nix { inherit iogx-inputs; };


  modularise = import ../lib/modularise.nix { inherit l; };


  libnixschema = import ../lib/libnixschema.nix { inherit l; };

  
  iogx-schemas = import ../schemas { inherit libnixschema; };


  mkInterface = repo-root: 
    let 
      mkOne = name: schema: 
        l.nameValuePair "load-${name}" (args: 
          let 
            config = l.importFileWithDefault {} "${repo-root}/nix/${name}.nix" args;
            value = libnixschema.validateConfig schema config ''
              IOGX: Your ./nix/${name}.nix has errors
              DOCS: http://www.github.com/input-output-hk/iogx/README.md#${name}
            '';
          in 
            value
        );
    in 
      l.mapAttrs' mkOne iogx-schemas;


  mkFlake = user-inputs: repo-root:
    let 
      iogx-interface = mkInterface repo-root;

      iogx-config = iogx-interface.load-iogx-config {}; 
      
      merged-inputs = iogx-inputs; # import ./merge-inputs.nix { inherit iogx-inputs user-inputs iogx-config l; };

      systemized-outputs = iogx-inputs.flake-utils.lib.eachSystem iogx-config.systems (system:
        let
          inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
          inputs' = merged-inputs;
          pkgs = import ./pkgs.nix { inherit iogx-inputs system; };
          root = ../.;
          module = "src";
          args = { inherit inputs inputs' pkgs iogx-config l iogx-interface; };
          src = modularise { inherit root module args; };
        in
        src.core.flake
      );

      top-level-outputs = iogx-interface.load-top-level-outputs { inputs' = merged-inputs; };

      # TODO check collisions 
      final-outputs = top-level-outputs // systemized-outputs;
    in  
      systemized-outputs;
      # final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake iogx-schemas; };


  out = { inherit lib; };

in

  out 

