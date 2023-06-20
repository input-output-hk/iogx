{ libnixschema, l }:

let

  V = libnixschema.validators;


  schema = {
    excludedPaths.type = V.list-of V.string;
    excludedPaths.default = []; 

    extraJobs.type = V.attrset;
    extraJobs.default = {};
  };

in

schema