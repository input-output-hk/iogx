{ missingField, invalidField, defaultField, successField }:

schema: 

let 

  config = {
    repoRoot = ../demo;
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    haskellCompilers = [ "ghc8107" ];
  };


  testsuite = [
    (missingField "iogx-config-01" config schema "repoRoot")
    (invalidField "iogx-config-02" config schema "repoRoot" "path-does-not-exist" ./__unknown)
    (invalidField "iogx-config-03" config schema "repoRoot" "dir-does-not-have-file" ./.)

    (missingField "iogx-config-04" config schema "systems")
    (invalidField "iogx-config-05" config schema "systems" "type-mismatch" { })
    (invalidField "iogx-config-06" config schema "systems" "invalid-list-elem" [ "x86_64-darwin" true ])
    (invalidField "iogx-config-07" config schema "systems" "empty-list" [ ])
    (invalidField "iogx-config-08" config schema "systems" "invalid-list-elem" [ "x" "y" ])

    (missingField "iogx-config-09" config schema "haskellCompilers")
    (invalidField "iogx-config-10" config schema "haskellCompilers" "type-mismatch" 1)
    (invalidField "iogx-config-11" config schema "haskellCompilers" "invalid-list-elem" [ "ghc8107" "ghcXXX" ])
    (invalidField "iogx-config-12" config schema "haskellCompilers" "empty-list" [ ])
    (invalidField "iogx-config-13" config schema "haskellCompilers" "invalid-list-elem" [ 1 "x" "y" ])

    (invalidField "iogx-config-14" config schema "defaultHaskellCompiler" "unknown-enum" 1)
    (invalidField "iogx-config-15" config schema "defaultHaskellCompiler" "unknown-enum" "ghcXXX")
    (defaultField "iogx-config-16" config schema "defaultHaskellCompiler" "ghc8107")

    (invalidField "iogx-config-17" config schema "shouldCrossCompile" "type-mismatch" [1])
    (successField "iogx-config-18" config schema "shouldCrossCompile" false)
    (defaultField "iogx-config-19" config schema "shouldCrossCompile" true)

    (invalidField "iogx-config-20" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite

