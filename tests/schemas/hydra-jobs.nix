{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {};

  
  schema = iogx-schemas.hydra-jobs;


  testsuite = [
    (invalidField config schema "excludedPaths" "type-mismatch" 1)
    (invalidField config schema "excludedPaths" "invalid-list-elem" ["a" 1])
    (defaultField config schema "excludedPaths" [])
    (successField config schema "excludedPaths" [])
    (successField config schema "excludedPaths" ["a"])
    (successField config schema "excludedPaths" ["a.b" "c.d.e"])

    (invalidField config schema "extraJobs" "type-mismatch" 1)
    (defaultField config schema "extraJobs" {})
    (successField config schema "extraJobs" {})
    (successField config schema "extraJobs" { a = 1; })
    (successField config schema "extraJobs" { a.b.c = {}; })

    (invalidField config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
