{ iogx-inputs }:

let

  l = import ../lib/l.nix { inherit iogx-inputs; };


  libnixschema = import ../lib/libnixschema.nix { inherit l; };


  modularise = import ../lib/modularise.nix { inherit l; };


  supported-systems = [ "x86_64-darwin" "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];


  iogx-schemas =
    let
      modules = [
        "cabal-project"
        "ci"
        "formatters"
        "haskell"
        "per-system-outputs"
        "read-the-docs"
        "shell"
        "top-level-outputs"
      ];

      getSchema = name:
        l.nameValuePair name
          (import ../modules/${
          name}/schema.nix libnixschema.validators);
    in
    l.listToAttrs (map getSchema modules);


  mkFlake =
    { inputs
    , systems ? [ "x86_64-darwin" "x86_64-linux" ]
    , repoRoot
    , config ? null
    , debug ? false
    }:
    let
      validated-systems = validateSystems systems;

      user-repo-root =
        if config == null then
          expectNixFolderInRepoRoot repoRoot
        else
          repoRoot;

      iogx-interface =
        if config == null then
          mkIogxInterfaceFromFolder repoRoot
        else
          mkIogxInterfaceFromConfig config;

      flake = l.mapAndRecursiveUpdateMany validated-systems (system:
        let
          inputs' = l.deSystemize system inputs;
          pkgs = mkPkgs iogx-inputs system;
          nix = modularise {
            root = user-repo-root + "/nix";
            module = "nix";
            args = {
              inherit inputs inputs' pkgs l;
              iogx = __src__;
            };
            inherit debug;
          };
          __src__ = modularise {
            root = ../.;
            module = "src";
            args = {
              inherit nix iogx-inputs inputs inputs' pkgs l;
              inherit iogx-interface system user-repo-root;
              inherit __flake__;
              iogx = __src__;
            };
            inherit debug;
          };
          __flake__ = __src__.iogx.flake-assembler;
        in
        l.injectAttrName system __flake__
      );

      flake' =
        let
          nix = modularise {
            root = user-repo-root + "/nix";
            module = "nix";
            args = { inherit inputs l; };
          };
          src = modularise {
            root = ../.;
            module = "src";
            args = { inherit nix iogx-inputs inputs l iogx-interface flake; };
          };
        in
        src.modules.top-level-outputs.makeTopLevelOutputs;
    in
    flake';


  expectNixFolderInRepoRoot = repoRoot:
    libnixschema.validateValueOrThrow {
      validator = libnixschema.validators.dir-with-file "nix";
      field = "The 'repoRoot' argument to iogx.lib.mkFlake";
      value = repoRoot;
      error = { result }: l.iogxError "flake" '' 
        Your flake.nix has errors:

        ${result.errmsg}
      '';
    };


  validateSystems = systems:
    libnixschema.validateValueOrThrow {
      validator = libnixschema.validators.nonempty-enum-list supported-systems;
      field = "The 'systems' argument to iogx.lib.mkFlake";
      value = systems;
      error = { result }: l.iogxError "flake" '' 
        Your flake.nix has errors:

        ${result.errmsg}
      '';
    };


  mkPkgs = iogx-inputs: system:
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

  # Returns this attrset:  
  # {
  #   "haskell.nix" = {
  #     exists = true; # "returns true if ./nix/haskell.nix exists 
  #     load = _: {}; # imports that file
  #   };
  #   "ci.nix" = {
  #     exists = false; # "returns true if ./nix/ci.nix exists 
  #     load = _: {}; # imports that file
  #   };
  #   ..
  # }
  mkIogxInterfaceFromConfig = config:
    let
      mkConfigErrmsg = name: { result }: l.iogxError name ''
        Your '${name}' field has errors:

        ${result.errmsg}
      '';

      mkInvalidFileErrmsg = name: l.iogxError name ''
        Your '${name}' field has errors:

        This field must either be an attrset, or a function taking an attrset.
      '';

      mkConfig = name: args:
        if l.hasAttr name config then
          let value = config.${name};
          in
          if l.typeOf value == "set" then
            value
          else if l.typeOf value == "lambda" then
            value args
          else
            mkInvalidFileErrmsg name
        else
          { };

      mkFileLoader = name: schema: args:
        libnixschema.validateConfigOrThrow {
          schema = schema;
          config = mkConfig name args;
          error = mkConfigErrmsg name;
        };

      mkNameValuePair = name: schema:
        l.nameValuePair "${name}.nix" {
          exists = l.hasAttr name config;
          load = mkFileLoader name schema;
        };
    in
    l.mapAttrs' mkNameValuePair iogx-schemas;


  mkIogxInterfaceFromFolder = repoRoot:
    let
      mkConfigErrmsg = name: { result }: l.iogxError name ''
        Your nix/${name}.nix has errors:

        ${result.errmsg}
      '';

      mkInvalidFileErrmsg = name: l.iogxError name ''
        Your nix/${name}.nix has errors:

        This file must either be an attrset, or a function taking an attrset.
      '';

      mkConfig = name: args:
        let path = repoRoot + "/nix/${name}.nix";
        in
        if l.pathExists path then
          let value = import path;
          in
          if l.typeOf value == "set" then
            value
          else if l.typeOf value == "lambda" then
            value args
          else
            mkInvalidFileErrmsg name
        else
          { };

      mkFileLoader = name: schema: args:
        libnixschema.validateConfigOrThrow {
          schema = schema;
          config = mkConfig name args;
          error = mkConfigErrmsg name;
        };

      mkNameValuePair = name: schema:
        l.nameValuePair "${name}.nix" {
          exists = l.pathExists (repoRoot + "/nix/${name}.nix");
          load = mkFileLoader name schema;
        };
    in
    l.mapAttrs' mkNameValuePair iogx-schemas;


  # support = l.mapAndRecursiveUpdateMany supported-systems (system:
  #   let
  #     pkgs = mkPkgs iogx-inputs system;
  #     src = modularise {
  #       root = ../.;
  #       module = "src";
  #       args = { inherit iogx-inputs pkgs l system; };
  #     };
  #   in
  #   l.injectAttrName system src
  # );


  lib = { inherit mkFlake l libnixschema modularise iogx-schemas; };


  iogx = { inherit lib; };

in

iogx 

