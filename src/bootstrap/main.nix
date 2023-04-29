# Given the iogx flake inputs, 
{ inputs }:

let
  iogx-inputs = inputs;

  l = import ./l.nix { inherit iogx-inputs; };

  modularise = import ./modularise.nix { inherit l; };

  mkFlake = user-inputs: unvalidated-flakeopts:
    let
      merged-inputs = import ./merge-inputs.nix { inherit iogx-inputs user-inputs; };
      flakeopts = import ./validate-flakeopts.nix { inherit unvalidated-flakeopts l; };
    in
    iogx-inputs.flake-utils.lib.eachSystem flakeopts.systems (system:
      let
        iogx = modularise {
          args = {
            inherit flakeopts l;
            inputs = merged-inputs.nosys.lib.deSys system merged-inputs;
            systemized-inputs = merged-inputs;
            pkgs = import ./pkgs.nix { inherit iogx-inputs system; };
          };
          src = ../.;
          module = "iogx";
        };
      in
      iogx.core.mkFlake
    );

in
{ inherit mkFlake l modularise; }


