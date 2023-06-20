{ libnixschema, l }:

let

  V = libnixschema.validators;


  schema = {
    cabalProjectLocal.type = V.string;
    cabalProjectLocal.default = "";

    sha256map.type = V.attrset;
    sha256map.default = {};

    shellWithHoogle.type = V.bool; 
    shellWithHoogle.default = false;

    packages.type = V.attrset;
    packages.default = {}; 
  };

in

schema
