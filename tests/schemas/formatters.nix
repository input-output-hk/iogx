{ missingField, invalidField, defaultField, successField }:

schema:

let

  config = { };


  testsuite = [
    (invalidField "formatters-01" config schema "cabal-fmt" "inner-schema-failure" { enable = 1; })
    (invalidField "formatters-02" config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField "formatters-03" config schema "cabal-fmt" "inner-schema-failure" { enable = true; extraOptions = "a"; x = 1; })
    (invalidField "formatters-04" config schema "cabal-fmt" "inner-schema-failure" { enabled = true; })
    (defaultField "formatters-05" config schema "cabal-fmt" { enable = false; extraOptions = ""; })
    (successField "formatters-06" config schema "cabal-fmt" { enable = true; extraOptions = ""; })
    (successField "formatters-07" config schema "cabal-fmt" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField "formatters-08" config schema "shellcheck" "inner-schema-failure" { enable = 1; })
    (invalidField "formatters-09" config schema "shellcheck" "inner-schema-failure" { enable = true; extraOptions = 1; })
    (invalidField "formatters-10" config schema "shellcheck" "inner-schema-failure" { enabled = true; })
    (defaultField "formatters-11" config schema "shellcheck" { enable = false; extraOptions = ""; })
    (successField "formatters-12" config schema "shellcheck" { enable = true; extraOptions = ""; })
    (successField "formatters-13" config schema "shellcheck" { enable = false; extraOptions = "Hello, World!"; })

    (invalidField "formatters-14" config schema "__unknown" "unknown-field" 1)
  ];

in

testsuite
