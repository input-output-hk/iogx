{ missingField, invalidField, defaultField, successField }:

schema: 

let 

  config = {};

  
  testsuite = [
    (invalidField "pre-commit-check-01" config schema "cabal-fmt" "inner-schema-failure" { enable = 1; })
    (invalidField "pre-commit-check-02" config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField "pre-commit-check-03" config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = "a"; x = 1; })
    (invalidField "pre-commit-check-04" config schema "cabal-fmt" "inner-schema-failure" { enabled = true; })
    (defaultField "pre-commit-check-05" config schema "cabal-fmt" { enable = false; extraOptions = ""; })
    (successField "pre-commit-check-06" config schema "cabal-fmt" { enable = true; extraOptions = ""; })
    (successField "pre-commit-check-07" config schema "cabal-fmt" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField "pre-commit-check-08" config schema "shellcheck" "inner-schema-failure" { enable = 1; })
    (invalidField "pre-commit-check-09" config schema "shellcheck" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField "pre-commit-check-10" config schema "shellcheck" "inner-schema-failure" { enabled = true; })
    (defaultField "pre-commit-check-11" config schema "shellcheck" { enable = false; extraOptions = ""; })
    (successField "pre-commit-check-12" config schema "shellcheck" { enable = true; extraOptions = ""; })
    (successField "pre-commit-check-13" config schema "shellcheck" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField "pre-commit-check-14" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
