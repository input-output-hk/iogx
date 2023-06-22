{ libnixschema }:

let

  V = libnixschema.validators;


  hook-schema = {
    enable.type = V.bool;
    enable.default = false;
   
    extraOptions.type = V.string;
    extraOptions.default = "";
  };

  
  default-hook = {
    enable = false;
    extraOptions = "";
  };


  schema = {
    
    cabal-fmt.type = V.schema hook-schema; 
    cabal-fmt.default = default-hook;

    stylish-haskell.type = V.schema hook-schema;
    stylish-haskell.default = default-hook;

    shellcheck.type = V.schema hook-schema;
    shellcheck.default = default-hook;

    prettier.type = V.schema hook-schema;
    prettier.default = default-hook;

    editorconfig-checker.type = V.schema hook-schema;
    editorconfig-checker.default = default-hook;
    
    nixpkgs-fmt.type = V.schema hook-schema;
    nixpkgs-fmt.default = default-hook;

    png-optimization.type = V.schema hook-schema;
    png-optimization.default = default-hook;
    
    fourmolu.type = V.schema hook-schema;
    fourmolu.default = default-hook;
    
    hlint.type = V.schema hook-schema;
    hlint.default = default-hook;
    
    hindent.type = V.schema hook-schema;
    hindent.default = default-hook;
  };


in

schema