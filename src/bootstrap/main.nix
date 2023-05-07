# Given the iogx flake inputs, 
{ iogx-inputs }:

let
  l = import ./l.nix { inherit iogx-inputs; };

  modularise = import ./modularise.nix { inherit l; };

  libnixschema = import ./libnixschema.nix { inherit l; };

  flakeopts-schema = import ./flakeopts-schema.nix { inherit l libnixschema; };

  mkFlake = unvalidated-flakeopts:
    let
      flakeopts = libnixschema.validateConfig flakeopts-schema unvalidated-flakeopts;

      merged-inputs = import ./merge-inputs.nix {
        inherit iogx-inputs flakeopts l;
        user-inputs = flakeopts.inputs;
      };
    in
    iogx-inputs.flake-utils.lib.eachSystem flakeopts.systems (system:
      let
        iogx = modularise {
          root = ../.;
          module = "iogx";
          args = {
            inherit flakeopts l;
            inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
            systemized-inputs = merged-inputs;
            pkgs = import ./pkgs.nix { inherit iogx-inputs system; };
          };
        };
      in
      iogx.core.mkFlake
    );

in
{ inherit mkFlake l libnixschema modularise flakeopts-schema iogx-inputs; }


