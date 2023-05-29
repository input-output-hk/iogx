{ libnixschema }:

let
  V = libnixschema.validators;

  schema = {
    inputs = V.attrset;
    debug = V.bool;
    flakeOutputsPrefix = V.string;
    repoRoot = V.dir-with-file "cabal.project";
    systems = V.nonempty-enum-list [ "x86_64-linux" "x86_64-darwin" ];
    haskellCompilers = V.nonempty-enum-list [ "ghc8107" "ghc927" ];
    defaultHaskellCompiler = V.enum [ "ghc8107" "ghc927" ];
    haskellCrossSystem = V.null-or (V.enum [ "x86_64-linux" "x86_64-darwin" ]);
    haskellProjectFile = V.path-exists;
    perSystemOutputsFile = V.null-or V.path-exists;
    shellPrompt = V.nonempty-string;
    shellWelcomeMessage = V.nonempty-string;
    shellModuleFile = V.null-or V.path-exists;
    includeHydraJobs = V.bool;
    excludeProfiledHaskellFromHydraJobs = V.bool;
    blacklistedHydraJobs = V.list-of V.string;
    enableHydraPreCommitCheck = V.bool;
    readTheDocsSiteDir = V.null-or V.path-exists;
    readTheDocsHaddockPrologue = V.string;
    readTheDocsExtraHaddockPackages = V.null-or V.function;
  };
in
schema
