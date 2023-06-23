{ missingField, invalidField, defaultField, successField }:

schema:

let 

  config = {};


  testsuite = [
    (invalidField "haskell-project-01" config schema "cabalProjectLocal" "type-mismatch" 1)
    (defaultField "haskell-project-02" config schema "cabalProjectLocal" "")
    (successField "haskell-project-03" config schema "cabalProjectLocal" "")
    (successField "haskell-project-04" config schema "cabalProjectLocal" "Hello, World!")

    (invalidField "haskell-prokect-05" config schema "sha256map" "type-mismatch" 1)
    (defaultField "haskell-prokect-06" config schema "sha256map" {})
    (successField "haskell-prokect-07" config schema "sha256map" {})
    (successField "haskell-prokect-08" config schema "sha256map" { a."b" = 1; })

    (invalidField "haskell-project-09" config schema "shellWithHoogle" "type-mismatch" 1)
    (defaultField "haskell-project-10" config schema "shellWithHoogle" false)
    (successField "haskell-project-11" config schema "shellWithHoogle" true)

    (invalidField "haskell-project-12" config schema "modules" "type-mismatch" 1)
    (defaultField "haskell-project-13" config schema "modules" [])
    (successField "haskell-project-14" config schema "modules" [])
    (successField "haskell-project-15" config schema "modules" [{ a.b = 1; }]) 

    (invalidField "haskell-project-16" config schema "__unknown" "unknown-field" 1)

    (invalidField "haskell-project-17" config schema "overlays" "type-mismatch" 1)
    (defaultField "haskell-project-18" config schema "overlays" [])
    (successField "haskell-project-19" config schema "overlays" [])
    (successField "haskell-project-20" config schema "overlays" [{ a.b = 1; }]) 
  ];

in 

  testsuite
