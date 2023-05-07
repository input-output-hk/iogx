{ iogx }:

let
  inherit (iogx) l libnixschema flakeopts-schema iogx-inputs;


  valid-config = {
    inputs = { };
    debug = true;
    repoRoot = ./.;
    flakeOutputsPrefix = "";
    systems = [ "x86_64-darwin" "x86_64-linux" ];
    haskellCompilers = [ "ghc8107" ];
    defaultHaskellCompiler = "ghc8107";
    haskellCrossSystem = null;
    haskellProjectFile = ./nix/haskell-project.nix;
    perSystemOutputsFile = ./nix/per-system-outputs.nix;
    shellName = "[TODO]";
    shellPrompt = "\n\\[\\033[1;32m\\][TODO:\\w]\\$\\[\\033[0m\\] ";
    shellWelcomeMessage = "🤟 \\033[1;31mWelcome to TODO\\033[0m 🤟";
    shellModuleFile = ./nix/shell-module.nix;
    includeHydraJobs = true;
    excludeProfiledHaskellFromHydraJobs = true;
    blacklistedHydraJobs = [ ];
    enableHydraPreCommitCheck = true;
    includeReadTheDocsSite = true;
    readTheDocsSiteDir = ./doc/read-the-docs-site;
    readTheDocsHaddockPrologue = "";
    readTheDocsExtraHaddockPackages = null;
  };


  expect-missing-field = error-field:
    expect-failure error-field "missing-field" [ error-field ] { };


  expect-invalid-field = error-field: error-tag: field-value:
    expect-failure error-field error-tag [ ] { ${error-field} = field-value; };


  expect-failure = error-field: error-tag: remove-fields: update-fields:
    let
      config = removeAttrs valid-config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema flakeopts-schema config;
    in
    if result.status != "failure" then
      l.throw ''
        flakeopts-schema-tests.nix:
        Test was successful
        Expected failure: ${error-field} ∷ ${error-tag}
      ''
    else
      let first = l.head result.errors; in
      if first.tag == error-tag && first.field == error-field then
        true
      else
        l.throw ''
          flakeopts-schema-tests.nix:
          Expected failure: ${error-field} ∷ ${error-tag}
          Actual failure: ${first.field} ∷ ${first.tag}
        '';


  testsuite = [
    (expect-missing-field "inputs")
    (expect-invalid-field "inputs" "type-mismatch" true)
    (expect-missing-field "debug")
    (expect-invalid-field "debug" "type-mismatch" 1)
    (expect-missing-field "repoRoot")
    (expect-invalid-field "repoRoot" "path-does-not-exist" ./__unknown)
    (expect-invalid-field "repoRoot" "dir-does-not-have-file" ./nix)
    (expect-missing-field "flakeOutputsPrefix")
    (expect-invalid-field "flakeOutputsPrefix" "type-mismatch" 1)
    (expect-missing-field "systems")
    (expect-invalid-field "systems" "type-mismatch" { })
    (expect-invalid-field "systems" "invalid-list-elem" [ "x86_64-darwin" true ])
    (expect-invalid-field "systems" "empty-list" [ ])
    (expect-invalid-field "systems" "invalid-list-elem" [ "x" "y" ])
    (expect-missing-field "haskellCompilers")
    (expect-invalid-field "haskellCompilers" "type-mismatch" 1)
    (expect-invalid-field "haskellCompilers" "invalid-list-elem" [ "ghc8107" "ghcXXX" ])
    (expect-invalid-field "haskellCompilers" "empty-list" [ ])
    (expect-invalid-field "haskellCompilers" "invalid-list-elem" [ 1 "x" "y" ])
    (expect-missing-field "haskellProjectFile")
    (expect-invalid-field "haskellProjectFile" "type-mismatch" true)
    (expect-invalid-field "haskellProjectFile" "path-does-not-exist" ./__unknown.nix)
    (expect-missing-field "perSystemOutputsFile")
    (expect-invalid-field "perSystemOutputsFile" "type-mismatch" true)
    (expect-invalid-field "perSystemOutputsFile" "path-does-not-exist" ./__unknown.nix)
    (expect-missing-field "shellName")
    (expect-invalid-field "shellName" "type-mismatch" true)
    (expect-invalid-field "shellName" "empty-string" "")
    (expect-missing-field "shellPrompt")
    (expect-invalid-field "shellPrompt" "type-mismatch" true)
    (expect-invalid-field "shellPrompt" "empty-string" "")
    (expect-missing-field "shellWelcomeMessage")
    (expect-invalid-field "shellWelcomeMessage" "type-mismatch" true)
    (expect-invalid-field "shellWelcomeMessage" "empty-string" "")
    (expect-missing-field "shellModuleFile")
    (expect-invalid-field "shellModuleFile" "type-mismatch" true)
    (expect-invalid-field "shellModuleFile" "path-does-not-exist" ./__unknown.nix)
    (expect-missing-field "includeHydraJobs")
    (expect-invalid-field "includeHydraJobs" "type-mismatch" 1)
    (expect-missing-field "excludeProfiledHaskellFromHydraJobs")
    (expect-invalid-field "excludeProfiledHaskellFromHydraJobs" "type-mismatch" 1)
    (expect-missing-field "blacklistedHydraJobs")
    (expect-invalid-field "blacklistedHydraJobs" "type-mismatch" 1)
    (expect-missing-field "enableHydraPreCommitCheck")
    (expect-invalid-field "enableHydraPreCommitCheck" "type-mismatch" 1)
    (expect-missing-field "includeReadTheDocsSite")
    (expect-invalid-field "includeReadTheDocsSite" "type-mismatch" 1)
    (expect-missing-field "readTheDocsSiteDir")
    (expect-invalid-field "readTheDocsSiteDir" "type-mismatch" true)
    (expect-invalid-field "readTheDocsSiteDir" "path-does-not-exist" ./__unknown.nix)
    (expect-missing-field "readTheDocsHaddockPrologue")
    (expect-invalid-field "readTheDocsHaddockPrologue" "type-mismatch" true)
    (expect-missing-field "readTheDocsExtraHaddockPackages")
    (expect-invalid-field "readTheDocsExtraHaddockPackages" "type-mismatch" true)
  ];


  evaluated-testsuite = l.deepSeq testsuite "success";


  run = iogx-inputs.nixpkgs.legacyPackages.x86_64-linux.writeScript "flakeopts-schema-tests" ''
    echo "Evaluating ./tests/flakeopts-schema-tests.nix ... ${evaluated-testsuite}"
  '';
in

run
