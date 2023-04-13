{ iogx-inputs, user-inputs }:

# TODO 
let
  user-inputs' = removeAttrs user-inputs [ "iogx" "self.inputs.iogx" ];
in
iogx-inputs // user-inputs' 
