{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {};

  
  schema = iogx-schemas.haskell-project;


  testsuite = [
    (invalidField config schema "cabalProjectLocal" "type-mismatch" 1)
    (defaultField config schema "cabalProjectLocal" "")
    (successField config schema "cabalProjectLocal" "")
    (successField config schema "cabalProjectLocal" "Hello, World!")

    (invalidField config schema "sha256map" "type-mismatch" 1)
    (defaultField config schema "sha256map" {})
    (successField config schema "sha256map" {})
    (successField config schema "sha256map" { a."b" = 1; })

    (invalidField config schema "shellWithHoogle" "type-mismatch" 1)
    (defaultField config schema "shellWithHoogle" false)
    (successField config schema "shellWithHoogle" true)

    (invalidField config schema "packages" "type-mismatch" 1)
    (defaultField config schema "packages" {})
    (successField config schema "packages" {})
    (successField config schema "packages" { a.b = 1; }) 

    (invalidField config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite
