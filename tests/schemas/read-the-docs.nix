{ missingField, invalidField, defaultField, successField }:

schema: 

let 

  config = {};


  testsuite = [
    (invalidField "read-the-docs-01" config schema "type-mismatch" 1)
    (successField "read-the-docs-03" config schema "siteFolder" "./docs")
    (defaultField "read-the-docs-04" config schema "siteFolder" null)

    (invalidField "read-the-docs-05" config schema "haddockPrologue" "type-mismatch" { })
    (successField "read-the-docs-06" config schema "haddockPrologue" "#")
    (defaultField "read-the-docs-07" config schema "haddockPrologue" "")

    (invalidField "read-the-docs-08" config schema "extraHaddockPackages" "type-mismatch" 1)
    (invalidField "read-the-docs-09" config schema "extraHaddockPackages" "invalid-list-elem" [ "plutus" 1 ])
    (successField "read-the-docs-10" config schema "extraHaddockPackages" [])
    (successField "read-the-docs-11" config schema "extraHaddockPackages" ["plutus"])
    (defaultField "read-the-docs-12" config schema "extraHaddockPackages" [])

    (invalidField "read-the-docs-13" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite