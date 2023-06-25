{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    excludedPaths.type = V.list-of V.string;
    excludedPaths.default = []; 

    includedPaths.type = V.list-of V.string;
    includedPaths.default = []; 

    includeProfiledBuilds.type = V.bool;
    includeProfiledBuilds.default = false;

    includePreCommitCheck.type = V.bool;
    includePreCommitCheck.default = true;
  };

in

schema