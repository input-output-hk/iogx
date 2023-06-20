{ iogx, pkgs }:

let
  inherit (iogx.lib) l libnixschema iogx-schemas;


  missingField = config: schema: error-field:
    expectFailure config schema error-field "missing-requred-field" [ error-field ] { };


  invalidField = config: schema: error-field: error-tag: field-value:
    expectFailure config schema error-field error-tag [ ] { ${error-field} = field-value; };


  defaultField = config: schema: field-name: field-value:
    expectSuccess config schema field-name field-value [ field-name ] { };


  successField = config: schema: field-name: field-value:
    expectSuccess config schema field-name field-value [ ] { ${field-name} = field-value; };


  expectSuccess = config: schema: field-name: field-value: remove-fields: update-fields:
    let
      config' = removeAttrs config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema schema config';
    in
    if result.status == "success" then
      let actual-value = result.config.${field-name}; in 
      if actual-value == field-value then 
        true 
      else 
        l.throw ''

          Wrong default value: ${field-name}
          Expected value: ${l.valueToString field-value}
          Actual value: ${l.valueToString actual-value}
        ''
    else
      let first = l.head result.errors; in
      l.throw ''

        Expected success: ${field-name} = ${l.valueToString field-value}
        Actual failure: ${first.field} ∷ ${first.tag}
        ${libnixschema.resultToErrorString first}
      '';


  expectFailure = config: schema: error-field: error-tag: remove-fields: update-fields:
    let
      config' = removeAttrs config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema schema config';
    in
    if result.status == "success" then
      l.throw ''

        Test was successful
        Expected failure: ${error-field} ∷ ${error-tag}
      ''
    else
      let first = l.head result.errors; in
      if first.tag == error-tag && first.field == error-field then
        true
      else
        l.throw ''

          Expected failure: ${error-field} ∷ ${error-tag}
          Actual failure: ${first.field} ∷ ${first.tag}
          ${libnixschema.resultToErrorString first}
        '';


  lib = { inherit missingField invalidField defaultField successField iogx-schemas; };


  testsuite = [
    (import ./schemas/haskell-project.nix lib)
    (import ./schemas/hydra-jobs.nix lib)
    (import ./schemas/iogx-config.nix lib)
    (import ./schemas/pre-commit-check.nix lib)
    (import ./schemas/shell.nix lib)
  ];


  evaluated-testsuite = l.deepSeq testsuite "success";


  run = pkgs.writeScript "testsuite" ''
    echo "Evaluating ./tests/main.nix ... ${evaluated-testsuite}"
  '';

in

run
