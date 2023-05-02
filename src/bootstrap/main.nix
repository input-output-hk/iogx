# Given the iogx flake inputs, 
{ iogx-inputs }:

let
  l = import ./l.nix { inherit iogx-inputs; };

  modularise = import ./modularise.nix { inherit l; };

  mkFlake = unvalidated-flakeopts:
    let
      flakeopts = import ./validate-flakeopts.nix { inherit unvalidated-flakeopts l; };

      merged-inputs = import ./merge-inputs.nix {
        inherit iogx-inputs;
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
{ inherit mkFlake l modularise; }


