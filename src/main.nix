{ iogx-inputs }:

let

  l = import ./lib/l.nix { inherit iogx-inputs; };


  modularise = import ./lib/modularise.nix { inherit l; };


  libnixschema = import ./lib/libnixschema.nix { inherit l; };

  
  iogx-schemas = import ./schemas { inherit libnixschema; };


  ensureRepoRootHasCabalProjectFile = { unvalidate-user-repo-root }: 
    libnixschema.validateValueOrThrow {
      validator = libnixschema.validators.dir-with-file "cabal.project";
      field = "\"repository root\"";
      value = unvalidate-user-repo-root;
      error = { result }: l.iogxError "flake" '' 
        Your flake.nix has errors:

        The second argument to the call to iogx.lib.mkFlake is invalid: 

        The path "${l.stripStoreFromNixPath unvalidate-user-repo-root}" does not exist or does not contain the cabal.project file.
      '';
    };

  
  mkIogxInterface = { user-repo-root }: 
    let 
      mkConfigErrmsg = file: { result }: l.iogxError file ''
        Your nix/${file}.nix has errors:

        ${result.errmsg}
      '';

      mkInvalidFileErrmsg = file: l.iogxError file ''
        Your nix/${file}.nix has errors:

        This file must either be an attrset, or a function taking an attrset.
      '';

      mkConfig = file: args: 
        let path = "${user-repo-root}/nix/${file}.nix"; 
        in if l.pathExists path then 
          let value = import path; 
          in if l.typeOf value == "set" then 
            value
          else if l.typeOf value == "lambda" then 
            value args 
          else 
            mkInvalidFileErrmsg file 
        else
          {};

      mkInterfaceFile = file: schema: args:
        libnixschema.validateConfigOrThrow schema (mkConfig file args) (mkConfigErrmsg file);

      mkNameValuePair = file: schema: 
        l.nameValuePair "load-${file}" (mkInterfaceFile file schema);
    in 
      l.mapAttrs' mkNameValuePair iogx-schemas;


  mkIogxConfig = { iogx-interface, merged-inputs }:
    let 
      iogx-config = iogx-interface.load-iogx-config { inputs' = merged-inputs; }; 
    in 
      iogx-config;
      

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


  mkPerSystemOutputs = { iogx-config, iogx-interface, merged-inputs, user-repo-root }:
    iogx-inputs.flake-utils.lib.eachSystem iogx-config.systems (system:
      let
        inputs = l.deSystemize system merged-inputs;
        inputs' = merged-inputs;
        pkgs = mkPkgs { inherit iogx-inputs system; };
        root = ./.;
        module = "src";
        args = { inherit inputs inputs' pkgs iogx-config l iogx-interface user-repo-root; };
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
        - Nonstandard flake outputs already defined in your nix/per-system-outputs.nix 
      '';
    in 
      l.mergeDisjointAttrsOrThrow top-level-outputs per-system-outputs mkErrmsg;


  mkFlake = user-inputs: unvalidate-user-repo-root:
    let 
      user-repo-root = ensureRepoRootHasCabalProjectFile { inherit unvalidate-user-repo-root; };

      iogx-interface = mkIogxInterface { inherit user-repo-root; };
      
      merged-inputs = mkMergedInputs { inherit user-inputs; }; 

      iogx-config = mkIogxConfig { inherit iogx-interface merged-inputs; };

      per-system-outputs = mkPerSystemOutputs { inherit iogx-config iogx-interface merged-inputs user-repo-root; };

      top-level-outputs = iogx-interface.load-top-level-outputs { inputs' = merged-inputs; };

      final-outputs = mkFinalOutputs { inherit per-system-outputs top-level-outputs; };
    in  
      final-outputs;

  
  lib = { inherit l modularise libnixschema mkFlake iogx-schemas; __mkPkgs__ = mkPkgs; };


  out = { inherit lib; };

in

  out 

