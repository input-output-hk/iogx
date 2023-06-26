{ iogx-inputs }:

let

  l = import ./lib/l.nix { inherit iogx-inputs; };


  modularise = import ./lib/modularise.nix { inherit l; };


  libnixschema = import ./lib/libnixschema.nix { inherit l; };

  
  iogx-schemas = import ./schemas { inherit libnixschema; };


  mkIogxInterface = { repo-root }: 
    let 
      mkErrmsg = file: { result }: l.iogxError file ''
        Your nix/${file}.nix has errors:

        ${result.errmsg}
      '';

      mkConfig = file: args: 
        let path = "${repo-root}/nix/${file}.nix"; 
        in if l.pathExists path then 
          if args == null then 
            import path # Some interface files take no inputs
          else 
            import path args 
        else
          {};

      mkInterfaceFile = file: schema: args:
        libnixschema.validateConfigOrThrow schema (mkConfig file args) (mkErrmsg file);

      mkNameValuePair = file: schema: 
        l.nameValuePair "load-${file}" (mkInterfaceFile file schema);
    in 
      l.mapAttrs' mkNameValuePair iogx-schemas;


  mkMergedInputs = { user-inputs }:
    let
      iogx-inputs-without-self = removeAttrs iogx-inputs [ "self" ];

      mkErrmsg = { n, duplicates }: l.iogxError "flake" ''
        Your flake.nix has ${l.toString n} unexpected ${l.plural n "input"}:

          ${l.concatStringsSep ", " duplicates}

        Those inputs are already managed by the IOGX flake.
        Do not duplicate them but override them if needed.
      '';
    in 
      l.mergeDisjointAttrsOrThrow user-inputs iogx-inputs-without-self mkErrmsg;


  mkPkgs = { iogx-inputs, system }:
    import iogx-inputs.nixpkgs {
      inherit system;
      config = iogx-inputs.haskell-nix.config;
      overlays = # WARNING: The order of these is crucial
        [
          iogx-inputs.iohk-nix.overlays.crypto
          iogx-inputs.iohk-nix.overlays.cardano-lib
          iogx-inputs.haskell-nix.overlay
          iogx-inputs.iohk-nix.overlays.haskell-nix-crypto
          iogx-inputs.iohk-nix.overlays.haskell-nix-extra
        ];
    };


  mkPerSystemOutputs = { iogx-config, iogx-interface, merged-inputs }:
    iogx-inputs.flake-utils.lib.eachSystem iogx-config.systems (system:
      let
        inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
        inputs' = merged-inputs;
        pkgs = mkPkgs { inherit iogx-inputs system; };
        root = ./.;
        module = "src";
        args = { inherit inputs inputs' pkgs iogx-config l iogx-interface; };
        src = modularise { inherit root module args; };
      in
      src.core.flake
    );


  mkFinalOutputs = { per-system-outputs, top-level-outputs }:
    let 
      mkErrmsg = { n, duplicates }: l.iogxError "top-level-outputs" ''
        Your nix/top-level-outputs.nix has ${toString n} invalid ${l.plural n "attribute"}:

          ${l.concatStringsSep ", " duplicates}

        Those attribute names are not acceptable because they are either:
        - Standard flake outputs such as: packages, devShells, apps, ...
        - Nonstandard flake outputs already defined in your ./nix/per-system-outputs.nix 
      '';
    in 
      l.mergeDisjointAttrsOrThrow top-level-outputs per-system-outputs mkErrmsg;


  mkFlake = user-inputs: repo-root:
    let 
      iogx-interface = mkIogxInterface { inherit repo-root; };

      iogx-config = iogx-interface.load-iogx-config null; 
      
      merged-inputs = mkMergedInputs { inherit user-inputs; }; 

      per-system-outputs = mkPerSystemOutputs { inherit iogx-config iogx-interface merged-inputs; };

      top-level-outputs = iogx-interface.load-top-level-outputs { inputs' = merged-inputs; };

      final-outputs = mkFinalOutputs { inherit per-system-outputs top-level-outputs; };
    in  
      final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake iogx-schemas; };


  out = { inherit lib; };

in

  out 

