{ iogx, pkgs }:

let
  inherit (iogx.lib) l libnixschema iogx-schemas;


  missingField = testcase: config: schema: error-field:
    expectFailure testcase config schema error-field "missing-requred-field" [ error-field ] { };


  invalidField = testcase: config: schema: error-field: error-tag: field-value:
    expectFailure testcase config schema error-field error-tag [ ] { ${error-field} = field-value; };


  defaultField = testcase: config: schema: field-name: field-value:
    expectSuccess testcase config schema field-name field-value [ field-name ] { };


  successField = testcase: config: schema: field-name: field-value:
    expectSuccess testcase config schema field-name field-value [ ] { ${field-name} = field-value; };


  expectSuccess = testcase: config: schema: field-name: field-value: remove-fields: update-fields:
    let
      config' = removeAttrs config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema schema config';
    in
    if result.status == "success" then
      let actual-value = result.config.${field-name}; in 
      if actual-value == field-value then 
        true 
      else 
        l.pthrow ''
          ------ ${testcase}
          Wrong default value: ${field-name}
          Expected value: ${l.valueToString field-value}
          Actual value: ${l.valueToString actual-value}
        ''
    else
      let first = l.head result.errors; in
      l.pthrow ''
        ------ ${testcase}
        Expected success: ${field-name} = ${l.valueToString field-value}
        Actual failure: ${first.field} ∷ ${first.tag}
        ${libnixschema.resultToErrorString first}
      '';


  expectFailure = testcase: config: schema: error-field: error-tag: remove-fields: update-fields:
    let
      config' = removeAttrs config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema schema config';
    in
    if result.status == "success" then
      l.pthrow ''
        ------ ${testcase}
        Test was successful
        Expected failure: ${error-field} ∷ ${error-tag}
      ''
    else
      let first = l.head result.errors; in
      if first.tag == error-tag && first.field == error-field then
        true
      else
        l.pthrow ''
          ------ ${testcase}
          Expected failure: ${error-field} ∷ ${error-tag}
          Actual failure: ${first.field} ∷ ${first.tag}
          ${libnixschema.resultToErrorString first}
        '';


  lib = { inherit missingField invalidField defaultField successField; };


  testsuite = [
    (import ./schemas/haskell-project.nix lib iogx-schemas.haskell-project)
    (import ./schemas/hydra-jobs.nix lib iogx-schemas.hydra-jobs)
    (import ./schemas/iogx-config.nix lib iogx-schemas.iogx-config)
    (import ./schemas/pre-commit-check.nix lib iogx-schemas.pre-commit-check)
    (import ./schemas/shell.nix lib iogx-schemas.shell)
    (import ./schemas/per-system-outputs.nix lib iogx-schemas.per-system-outputs)
    (import ./schemas/top-level-outputs.nix lib iogx-schemas.top-level-outputs)
    (import ./schemas/read-the-docs.nix lib iogx-schemas.read-the-docs)
  ];


  evaluated-testsuite = l.deepSeq testsuite "success";


  run = pkgs.writeScript "testsuite" ''
    echo "Evaluating ./tests/main.nix ... ${evaluated-testsuite}"
  '';

in

run
