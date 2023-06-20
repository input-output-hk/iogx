{ iogx-inputs, user-inputs, iogx-config, l }:

let

  iogx-inputs-without-self = removeAttrs iogx-inputs [ "self" ];


  common-inputs =
    l.intersectLists
      (l.attrNames user-inputs)
      (l.attrNames iogx-inputs-without-self);


  num-common-inputs = l.length common-inputs;


  inlined-common-inputs = l.concatStringsSep "\n- " common-inputs;


  debug-message = ''
    IOGX: Your flake.nix has ${l.toString num-common-inputs} unexpected inputs
    DOCS: http://www.github.com/input-output-hk/iogx/README.md#iogx-config

    These inputs are already managed by the IOGX flake.
    Do not duplicate them but override them if needed.
    - ${inlined-common-inputs}
  '';


  should-throw = num-common-inputs > 0;


  final-inputs = user-inputs // iogx-inputs-without-self;

in

l.pthrowIf should-throw debug-message final-inputs

