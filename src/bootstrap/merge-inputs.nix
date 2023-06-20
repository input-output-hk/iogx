{ iogx-inputs, user-inputs, iogx-config, l }:

let

  iogx-inputs-without-self = removeAttrs iogx-inputs [ "self" ];


  common-inputs =
    l.intersectLists
      (l.attrNames user-inputs)
      (l.attrNames iogx-inputs-without-self);


  num-common-inputs = l.length common-inputs;


  inlined-common-inputs = l.concatStringsSep "\n  - " common-inputs;


  fst-common-input = l.head common-inputs;


  debug-message = ''
    
    ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
    Your flake has ${l.toString num-common-inputs} unexpected inputs.
    The inputs listed below are already managed by the IOGX flake.
    You should not need to duplicate them in your flake.
    Instead, you should override them like this:

      inputs = {
        ${fst-common-input} = {
          url = "github:input-output-hk/${fst-common-input}";
        };
        iogx.url = "github:input-output-hk/iogx";
        iogx.inputs.${fst-common-input}.follows = "${fst-common-input}";
      }

    The clashing inputs are: 
      - ${inlined-common-inputs}
    ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️
  ''; # TODO turn into error


  should-throw = num-common-inputs > 0;


  final-inputs = user-inputs // iogx-inputs-without-self;

in

l.throwIf should-throw debug-message final-inputs

