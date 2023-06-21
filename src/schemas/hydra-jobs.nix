{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    excludedPaths.type = V.list-of V.string;
    excludedPaths.default = []; 

    includedPaths.type = V.list-of V.string;
    includedPaths.default = []; 

    extraJobs.type = V.attrset;
    extraJobs.default = {};
  };

in

schema