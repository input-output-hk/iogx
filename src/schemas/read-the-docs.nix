{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    
    siteFolder.type = V.null-or V.nonempty-string;
    siteFolder.default = null;

    haddockPrologue.type = V.string;
    haddockPrologue.default = "";

    extraHaddockPackages.type = V.list-of V.string;
    extraHaddockPackages.default = []; 
  };

in

schema