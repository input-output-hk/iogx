{ libnixschema, l }:

let

  V = libnixschema.validators;


  schema = {
    repoRoot.type = V.dir-with-file "cabal.project";
   
    systems.type = V.nonempty-enum-list [ "x86_64-linux" "x86_64-darwin" ];
   
    haskellCompilers.type = V.nonempty-enum-list [ "ghc8107" "ghc927" ];
   
    defaultHaskellCompiler.type = V.enum [ "ghc8107" "ghc927" ];
    defaultHaskellCompiler.default = conf: l.head conf.haskellCompilers; 
   
    shouldCrossCompile.type = V.bool;
    shouldCrossCompile.default = true;
  };

in

schema
