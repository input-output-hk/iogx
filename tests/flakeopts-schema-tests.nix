{ l, libnixschema, flakeopts-schema }:

let
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
    includeReadTheDocsSite = false;
    readTheDocsSiteDir = ./doc/read-the-docs-site;
    readTheDocsHaddockPrologue = "";
    readTheDocsExtraHaddockPackages = _: { };
  };

  expect-failure = error-field: error-tag: remove-fields: update-fields:
    let
      config = removeAttrs valid-config remove-fields // update-fields;
      result = libnixschema.matchConfigAgainstSchema flakeopts-schema config;
    in
    if result.status != "failure" then
      l.throw ''
        [flakeopts-schema-tests] 
        Expected failure: ${error-field} / ${error-tag}
      ''
    else
      let
        first = l.head (l.trace result.results result.results);
      in
      if first.tag == error-tag && first.field == error-field then
        "ok"
      else
        l.throw ''
          [flakeopts-schema-tests] 
          Expected failure: ${error-field} / ${error-tag}
          Actual failure: ${first.field} / ${first.tag}
        '';

  testcases = [
    (expect-failure "inputs" "missing-required-field" [ "inputs" ] { })
    (expect-failure "inputs" "simple-type-mismatch" [ ] { inputs = true; })

    (expect-failure "debug" "simple-type-mismatch" [ ] { debug = 1; })

    # (expect-failure "repoRoot" "missing-required-field" [ "repoRoot" ] { })
    (expect-failure "repoRoot" "path-does-not-exist" [ ] { repoRoot = ./__unknown; })
    # (expect-failure "repoRoot" "dir-does-not-have-file" [ ] { repoRoot = ./.; })

    # (expect-failure "flakeOutputsPrefix" "simple-type-mismatch" [ ] { flakeOutputsPrefix = { }; })

    # (expect-failure "systems" "simple-type-mismatch" [ ] { systems = [ 1 ]; })
    # (expect-failure "systems" "simple-type-mismatch" [ ] { systems = [ "x86_64-darwin" true ]; })
    # (expect-failure "systems" "empty-enum-list" [ ] { systems = [ ]; })
    # (expect-failure "systems" "many-unknown-enums" [ ] { systems = [ "x" "y" ]; })
  ];
in
l.deepSeq testcases "flakeopts-schema-tests-success"
