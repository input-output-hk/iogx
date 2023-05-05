{ l, libnixschema }:

let
  V = libnixschema.validators;

  schema = {
    inputs = V.attrset;
    debug = V.bool;
    repoRoot = V.dir-with-file "cabal.project";
    flakeOutputsPrefix = V.string;
    systems = V.nonempty-enum-list V.string [ "x86_64-linux" "x86_64-darwin" ];
    haskellCompilers = V.nonempty-enum-list V.string [ "ghc8107" "ghc925" ];
    defaultHaskellCompiler = V.enum V.string [ "ghc8107" "ghc925" ];
    haskellCrossSystem = V.null-or (V.enum V.string [ "x86_64-linux" "x86_64-darwin" ]);
    haskellProjectFile = V.path-exists;
    perSystemOutputsFile = V.null-or V.path-exists;
    shellName = V.nonempty-string;
    shellPrompt = V.nonempty-string;
    shellWelcomeMessage = V.nonempty-string;
    shellModuleFile = V.null-or V.path-exists;
    includeHydraJobs = V.bool;
    excludeProfiledHaskellFromHydraJobs = V.bool;
    blacklistedHydraJobs = V.list V.string;
    enableHydraPreCommitCheck = V.bool;
    includeReadTheDocsSite = V.bool;
    readTheDocsSiteDir = V.null-or V.path-exists;
    readTheDocsHaddockPrologue = V.string;
    readTheDocsExtraHaddockPackages = V.function;
  };
in
schema
