{ flakeopts, l, iogx-inputs, user-inputs }:

let
  iogx-inputs-without-self = removeAttrs iogx-inputs [ "self" ];

  common-inputs =
    l.intersectLists
      (l.attrNames user-inputs)
      (l.attrNames iogx-inputs-without-self);

  num-common-inputs = l.length common-inputs;

  pretty-common-inputs = l.concatStringsSep "\n- " common-inputs;

  debug-message = ''
    
    ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
    Your flake has ${l.toString num-common-inputs} unexpected inputs.
    The inputs listed below are already managed by the IOGX flake.
    You should not need to duplicate them in your flake.
    Instead, you should override them like so:
    inputs = {
      iogx.inputs.${l.head common-inputs}.url = "override-me";
    } 
    The clashing inputs are: 
    - ${pretty-common-inputs}
    ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
  '';

  should-trace = flakeopts.debug && num-common-inputs > 0;

  final-inputs = user-inputs // iogx-inputs-without-self;
in
l.warnIf should-trace debug-message final-inputs

