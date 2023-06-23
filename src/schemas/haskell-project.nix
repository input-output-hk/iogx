{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    cabalProjectLocal.type = V.string;
    cabalProjectLocal.default = "";

    sha256map.type = V.attrset;
    sha256map.default = {};

    shellWithHoogle.type = V.bool; 
    shellWithHoogle.default = false;

    modules.type = V.list;
    modules.default = []; 

    overlays.type = V.list;
    overlays.default = [];
  };

in

schema
