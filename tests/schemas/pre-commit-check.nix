{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {};

  
  schema = iogx-schemas.pre-commit-check;


  testsuite = [
    (invalidField config schema "cabal-fmt" "inner-schema-failure" { enable = 1; })
    (invalidField config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = "a"; x = 1; })
    (invalidField config schema "cabal-fmt" "inner-schema-failure" { enabled = true; })
    (defaultField config schema "cabal-fmt" { enable = false; extraOptions = ""; })
    (successField config schema "cabal-fmt" { enable = true; extraOptions = ""; })
    (successField config schema "cabal-fmt" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField config schema "shellcheck" "inner-schema-failure" { enable = 1; })
    (invalidField config schema "shellcheck" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField config schema "shellcheck" "inner-schema-failure" { enabled = true; })
    (defaultField config schema "shellcheck" { enable = false; extraOptions = ""; })
    (successField config schema "shellcheck" { enable = true; extraOptions = ""; })
    (successField config schema "shellcheck" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
