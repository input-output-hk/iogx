{ missingField, invalidField, defaultField, successField }:

schema:

let

  config = { };


  testsuite = [
    (invalidField "read-the-docs-01" config schema "type-mismatch" 1)
    (successField "read-the-docs-03" config schema "siteFolder" "./docs")
    (defaultField "read-the-docs-04" config schema "siteFolder" null)

    (invalidField "read-the-docs-13" config schema "__unknown" "unknown-field" 1)
  ];

in

testsuite
