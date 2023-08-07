{ missingField, invalidField, defaultField, successField }:

schema:

let

  config = { };


  testsuite = [
    (invalidField "cabal-project-01" config schema "cabalProjectLocal" "type-mismatch" 1)
    (defaultField "cabal-project-02" config schema "cabalProjectLocal" "")
    (successField "cabal-project-03" config schema "cabalProjectLocal" "")
    (successField "cabal-project-04" config schema "cabalProjectLocal" "Hello, World!")

    (invalidField "cabal-project-05" config schema "sha256map" "type-mismatch" 1)
    (defaultField "cabal-project-06" config schema "sha256map" { })
    (successField "cabal-project-07" config schema "sha256map" { })
    (successField "cabal-project-08" config schema "sha256map" { a."b" = 1; })

    (invalidField "cabal-project-09" config schema "shellWithHoogle" "type-mismatch" 1)
    (defaultField "cabal-project-10" config schema "shellWithHoogle" false)
    (successField "cabal-project-11" config schema "shellWithHoogle" true)

    (invalidField "cabal-project-12" config schema "modules" "type-mismatch" 1)
    (defaultField "cabal-project-13" config schema "modules" [ ])
    (successField "cabal-project-14" config schema "modules" [ ])
    (successField "cabal-project-15" config schema "modules" [{ a.b = 1; }])

    (invalidField "cabal-project-16" config schema "__unknown" "unknown-field" 1)

    (invalidField "cabal-project-17" config schema "overlays" "type-mismatch" 1)
    (defaultField "cabal-project-18" config schema "overlays" [ ])
    (successField "cabal-project-19" config schema "overlays" [ ])
    (successField "cabal-project-20" config schema "overlays" [{ a.b = 1; }])
  ];

in

testsuite
