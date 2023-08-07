{ missingField, invalidField, defaultField, successField }:

schema:

let

  config = {
    supportedCompilers = [ "ghc8107" ];
  };


  testsuite = [
    (invalidField "haskell-10" config schema "supportedCompilers" "type-mismatch" 1)
    (invalidField "haskell-11" config schema "supportedCompilers" "invalid-list-elem" [ "ghc8107" "ghcXXX" ])
    (invalidField "haskell-12" config schema "supportedCompilers" "empty-list" [ ])
    (invalidField "haskell-13" config schema "supportedCompilers" "invalid-list-elem" [ 1 "x" "y" ])

    (invalidField "haskell-17" config schema "enableCrossCompilation" "type-mismatch" [ 1 ])
    (successField "haskell-18" config schema "enableCrossCompilation" false)
    (defaultField "haskell-19" config schema "enableCrossCompilation" true)

    (invalidField "haskell-20" config schema "__unknown" "unknown-field" 1)
  ];

in

testsuite
