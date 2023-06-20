{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {};

  
  schema = iogx-schemas.hydra-jobs;


  testsuite = [
    (invalidField "hydra-jobs-01" config schema "excludedPaths" "type-mismatch" 1)
    (invalidField "hydra-jobs-02" config schema "excludedPaths" "invalid-list-elem" ["a" 1])
    (defaultField "hydra-jobs-03" config schema "excludedPaths" [])
    (successField "hydra-jobs-04" config schema "excludedPaths" [])
    (successField "hydra-jobs-05" config schema "excludedPaths" ["a"])
    (successField "hydra-jobs-06" config schema "excludedPaths" ["a.b" "c.d.e"])

    (invalidField "hydra-jobs-07" config schema "extraJobs" "type-mismatch" 1)
    (defaultField "hydra-jobs-08" config schema "extraJobs" {})
    (successField "hydra-jobs-09" config schema "extraJobs" {})
    (successField "hydra-jobs-10" config schema "extraJobs" { a = 1; })
    (successField "hydra-jobs-11" config schema "extraJobs" { a.b.c = {}; })

    (invalidField "hydra-jobs-12" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
