{ l, nix, iogx-interface, inputs, flake, ... }:

let

  top-level-outputs = iogx-interface."top-level-outputs.nix".load
    { inherit nix inputs l; };


  mkErrmsg = { n, duplicates }: l.iogxError "top-level-outputs" ''
    Your nix/top-level-outputs.nix has ${toString n} invalid ${l.plural n "attribute"}:

      ${l.concatStringsSep ", " duplicates}

    Those attribute names are not acceptable because they are either:
    - Standard flake outputs such as: packages, devShells, apps, ...
    - Nonstandard flake outputs already defined in your nix/per-system-outputs.nix 
  '';

  result =
    l.mergeDisjointAttrsOrThrow top-level-outputs flake mkErrmsg;

in

result
