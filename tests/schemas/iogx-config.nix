{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {
    repoRoot = ../demo;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    haskellCompilers = [ "ghc8107" ];
  };

  
  schema = iogx-schemas.iogx-config;


  testsuite = [
    (missingField config schema "repoRoot")
    (invalidField config schema "repoRoot" "path-does-not-exist" ./__unknown)
    (invalidField config schema "repoRoot" "dir-does-not-have-file" ./.)

    (missingField config schema "systems")
    (invalidField config schema "systems" "type-mismatch" { })
    (invalidField config schema "systems" "invalid-list-elems" [ "x86_64-darwin" true ])
    (invalidField config schema "systems" "empty-list" [ ])
    (invalidField config schema "systems" "invalid-list-elem" [ "x" "y" ])

    (missingField config schema "haskellCompilers")
    (invalidField config schema "haskellCompilers" "type-mismatch" 1)
    (invalidField config schema "haskellCompilers" "invalid-list-elem" [ "ghc8107" "ghcXXX" ])
    (invalidField config schema "haskellCompilers" "empty-list" [ ])
    (invalidField config schema "haskellCompilers" "invalid-list-elem" [ 1 "x" "y" ])

    (invalidField config schema "defaultHaskellCompiler" "unknown-enum" 1)
    (invalidField config schema "defaultHaskellCompiler" "unknown-enum" "ghcXXX")
    (defaultField config schema "defaultHaskellCompiler" "ghc8107")

    (invalidField config schema "shouldCrossCompile" "type-mismatch" [1])
    (successField config schema "shouldCrossCompile" false)
    (defaultField config schema "shouldCrossCompile" true)

    (invalidField config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite

