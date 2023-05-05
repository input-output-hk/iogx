{ flakeopts, l, iogx-inputs, user-inputs }:

let
  common-inputs = l.intersect (l.attrNames user-inputs) (l.attrNames iogx-inputs);

  num-common-inputs = l.listLength common-inputs;

  pretty-common-inputs = l.concatStringsSep "\n  " common-inputs;

  debug-message = ''
    [IOGX] warning: your flake has ${l.toString num-common-inputs} unexpected inputs.
    The inputs listed below are already managed by the IOGX flake.
    You should not need to duplicate them in your flake.
    Instead, you should override them like so:
    inputs = {
      iogx.inputs.${l.head common-inputs}.url = "override-me";
    } 
    The clashing inputs are: 
      ${pretty-common-inputs}
  '';

  should-trace = flakeopts.debug && num-common-inputs > 0;

  final-inputs = user-inputs // iogx-inputs // { self = user-inputs.self; };
in
l.traceIf should-trace debug-message final-inputs

