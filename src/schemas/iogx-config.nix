{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    systems.type = V.nonempty-enum-list [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
    systems.default = [ "x86_64-linux" ];

    haskellCompilers.type = V.nonempty-enum-list [ "ghc8107" "ghc927" "ghc928" ];

    defaultHaskellCompiler.type = V.enum [ "ghc8107" "ghc927" "ghc928" ];
    defaultHaskellCompiler.default = conf: builtins.head conf.haskellCompilers;

    shouldCrossCompile.type = V.bool;
    shouldCrossCompile.default = true;
  };

in

schema
