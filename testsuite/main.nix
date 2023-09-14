{ inputs, pkgs, lib, ... }:

let

  testcases."mergeDisjointAttrsDetectDuplicates" = [{
    name = "test-1";
    attrset1 = { a = 1; };
    attrset2 = { a = 1; };
    duplicates = [ ];
    value = { a.b = 2; c = 3; };
  }
    {
      name = "test-2";
      attrset1 = { a = 1; };
      attrset2 = { a = 1; };
      duplicates = [ ];
      value = { a.b = 2; c = 3; };
    }
    {
      name = "test-3";
      attrset1 = { a = 1; };
      attrset2 = { a = 1; };
      duplicates = [ ];
      value = { a.b = 2; c = 3; };
    }];


  run."mergeDisjointAttrsDetectDuplicates" = testcase:
    let
      result = inputs.self.lib.mergeDisjointAttrsDetectDuplicates testcase.attrset;
      if result.duplicates != testcase.duplicates then
      throw ''
        ------ mergeDisjointAttrsDetectDuplicates/${testcase.name}
        Expected Duplicates: 
          ${testcase.duplicates}
        Actual Duplicates:
          ${result.duplicates}
      ''
      else if result.value == != testcase.value then
      throw ''
        ------ mergeDisjointAttrsDetectDuplicates/${testcase.name}
        Expected Value: 
          ${testcase.value}
        Actual Value:
          ${result.value}
      ''
      else
      "success";


      testsuite =
        (map
          run."recursiveUpdateManyDetectDuplicates"
          testcases."recursiveUpdateManyDetectDuplicates");


      main = pkgs.writeScript "testsuite" ''
        echo "${lib.deepSeq testsuite "success"}"
      '';

    in

    main

