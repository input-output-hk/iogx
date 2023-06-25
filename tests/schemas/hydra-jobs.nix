{ missingField, invalidField, defaultField, successField }:

schema: 

let 

  config = {};


  testsuite = [
    (invalidField "hydra-jobs-01" config schema "excludedPaths" "type-mismatch" 1)
    (invalidField "hydra-jobs-02" config schema "excludedPaths" "invalid-list-elem" ["a" 1])
    (defaultField "hydra-jobs-03" config schema "excludedPaths" [])
    (successField "hydra-jobs-04" config schema "excludedPaths" [])
    (successField "hydra-jobs-05" config schema "excludedPaths" ["a"])
    (successField "hydra-jobs-06" config schema "excludedPaths" ["a.b" "c.d.e"])

    (invalidField "hydra-jobs-07" config schema "includedPaths" "type-mismatch" 1)
    (invalidField "hydra-jobs-08" config schema "includedPaths" "invalid-list-elem" ["a" 1])
    (defaultField "hydra-jobs-09" config schema "includedPaths" [])
    (successField "hydra-jobs-10" config schema "includedPaths" [])
    (successField "hydra-jobs-11" config schema "includedPaths" ["a"])
    (successField "hydra-jobs-12" config schema "includedPaths" ["a.b" "c.d.e"])

    (invalidField "hydra-jobs-13" config schema "includeProfiledBuilds" "type-mismatch" 1)
    (defaultField "hydra-jobs-14" config schema "includeProfiledBuilds" false)
    (successField "hydra-jobs-15" config schema "includeProfiledBuilds" true)

    (invalidField "hydra-jobs-16" config schema "includePreCommitCheck" {})
    (defaultField "hydra-jobs-17" config schema "includePreCommitCheck" true)
    (successField "hydra-jobs-18" config schema "includePreCommitCheck" false)

    (invalidField "hydra-jobs-19" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
