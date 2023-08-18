{ iogx-inputs }:

let

  l = import ../lib/l.nix { inherit iogx-inputs; };


  libnixschema = import ../lib/libnixschema.nix { inherit l; };


  modularise = import ../lib/modularise.nix { inherit l; };


  supported-systems = [
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-darwin"
    "aarch64-linux"
  ];


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
          (import (../modules + "/${name}/schema.nix") libnixschema.validators);
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
          repoRoot = modularise {
            root = user-repo-root;
            module = "repoRoot";
            args = {
              inherit inputs inputs' pkgs system;
              lib = l;
              iogxRepoRoot = __src__;
            };
            inherit debug;
          };
          __src__ = modularise {
            root = ../.;
            module = "src";
            args = {
              inherit repoRoot inputs inputs' pkgs l system;
              inherit iogx-inputs iogx-interface user-repo-root __flake__;
              iogxRepoRoot = __src__;
            };
            inherit debug;
          };
          __flake__ = __src__.iogx.flake-assembler;
        in
        l.injectAttrName system __flake__
      );

      flake' =
        let
          repoRoot = modularise {
            root = user-repo-root;
            module = "repoRoot";
            args = {
              inherit inputs;
              lib = l;
            };
          };
          src = modularise {
            root = ../.;
            module = "src";
            args = { inherit repoRoot iogx-inputs inputs l iogx-interface flake; };
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


  lib = { inherit mkFlake l libnixschema modularise iogx-schemas; };


  iogx = { inherit lib; };

in

iogx 

