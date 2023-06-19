{ libnixschema }:

let

  V = libnixschema.validators;


  schema = {
    debug = V.bool;
    repoRoot = V.dir-with-file "cabal.project";
    systems = V.nonempty-enum-list [ "x86_64-linux" "x86_64-darwin" ];
    haskellCompilers = V.nonempty-enum-list [ "ghc8107" "ghc927" ];
    defaultHaskellCompiler = V.enum [ "ghc8107" "ghc927" ];
    shouldCrossCompile = V.bool;
    haskellProjectFile = V.path-exists;
    perSystemOutputsFile = V.null-or V.path-exists;
    topLevelOutputsFile = V.null-or V.path-exists;
    shellFile = V.null-or V.path-exists;
    hydraJobsFile = V.null-or V.path-exists;
    readTheDocsFile = V.null-or V.path-exists;
    preCommitCheckFile = V.null-or V.path-exists;
  };

in

schema
