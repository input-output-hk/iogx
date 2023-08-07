{ missingField, invalidField, defaultField, successField }:

schema:

let

  config = { };


  testsuite = [
    (invalidField "ci-01" config schema "excludedPaths" "type-mismatch" 1)
    (invalidField "ci-02" config schema "excludedPaths" "invalid-list-elem" [ "a" 1 ])
    (defaultField "ci-03" config schema "excludedPaths" [ ])
    (successField "ci-04" config schema "excludedPaths" [ ])
    (successField "ci-05" config schema "excludedPaths" [ "a" ])
    (successField "ci-06" config schema "excludedPaths" [ "a.b" "c.d.e" ])

    (invalidField "ci-07" config schema "includedPaths" "type-mismatch" 1)
    (invalidField "ci-08" config schema "includedPaths" "invalid-list-elem" [ "a" 1 ])
    (defaultField "ci-09" config schema "includedPaths" [ ])
    (successField "ci-10" config schema "includedPaths" [ ])
    (successField "ci-11" config schema "includedPaths" [ "a" ])
    (successField "ci-12" config schema "includedPaths" [ "a.b" "c.d.e" ])

    (invalidField "ci-19" config schema "__unknown" "unknown-field" 1)
  ];

in

testsuite
