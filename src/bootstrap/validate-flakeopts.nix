{ unvalidated-flakeopts, l }:

let

  optionalFile = path:
    if l.pathExists path then import path else _: { };


  validateOptions =
    { inputs ? { }
    , debug ? false
    , flakeOutputsPrefix ? ""
    , systems ? [ "x86_64-linux" "x86_64-darwin" ]
    , repoRoot
    , haskellCompilers ? [ "ghc8107" ]
    , defaultHaskellCompiler ? l.head haskellCompilers
    , haskellCrossSystem ? null
    , haskellProjectFile ? optionalFile (repoRoot + "/nix/haskell-project.nix")
      # Selective including
    , includeHaskellApps ? true
    , includeHaskellChecks ? true
    , includeHaskellPackages ? true
      # devShells
    , includeDevShells ? true
    , shellName ? "iogx"
    , shellPrompt ? "\n\\[\\033[1;32m\\][${shellName}:\\w]\\$\\[\\033[0m\\] "
    , shellModule ? optionalFile (repoRoot + "/nix/shell-module.nix")
      # pre-commit-check
    , enablePreCommitCheck ? true
      # hydraJobs
    , includeHydraJobs ? true
    , blacklistedHydraJobs ? [ ]
    , excludeProfiledHaskellFromHydraJobs ? true
    , includedFlakeOutputsInHydraJobs ? [ "packages" "apps" "checks" "devShells" "roots" "coverage" "required" ]
      # ReadTheDocsSite
    , includeReadTheDocsSite ? false
    , readTheDocsSiteRoot ? repoRoot + "/doc"
    , readTheDocsHaddockPrologue ? ""
    , readTheDocsExtraHaddockPackages ? _: [ ]
      # Custom perSystemOutputs
    , perSystemOutputs ? optionalFile (repoRoot + "/nix/per-system-outputs.nix") # TODO rename 
    }:
    {
      inherit
        inputs
        debug
        flakeOutputsPrefix
        systems
        repoRoot
        haskellCompilers
        defaultHaskellCompiler
        haskellCrossSystem
        haskellProjectFile
        includeHaskellApps
        includeHaskellChecks
        includeHaskellPackages
        includeDevShells
        shellName
        shellPrompt
        shellModule
        enablePreCommitCheck
        includeHydraJobs
        blacklistedHydraJobs
        excludeProfiledHaskellFromHydraJobs
        includedFlakeOutputsInHydraJobs
        includeReadTheDocsSite
        readTheDocsSiteRoot
        readTheDocsHaddockPrologue
        readTheDocsExtraHaddockPackages
        perSystemOutputs;
    };
in
validateOptions unvalidated-flakeopts

# invalidField = name: value: message: l.throw ''
#   Error validating `mkFlake` configuration!
#   Invalid value `${value}` for field `${field}`:
#   ${message}
# '';

# c = unverified-config;

# validatedDebug = 
#   if c ? debug then 
#     if l.types.isBool c.debug then
#       c.debug 
#     else 
#       invalidField "Expecting a boolean."
#   else 
#     false;

# validatedSystems =
#   let supportedSystems = [ "x86_64-linux" "x86_64-darwin" ]; in
#   if c ? systems then
#     if ( 
#       l.types.isListOf l.types.string c.systems &&
#       l.length c.systems > 0 &&  
#       l.all (l.elem supportedSystems)
#     ) then 
#       c.systems
#     else 
#       invalidField ''
#         Expecting a non-empty list of strings from `${supportedSystems}`.
#       ''
#   else
#     invalidField ''
#       This field is required and must be a list of strings from `${supportedSystems}`.
#     '';

#   repoRoot =
#     if c ? repoRoot then
#       c.repoRoot
#     else
#       defaultWithTrace "repoRoot" self;

#   cabalProjectFile =
#     let
#       fp = repoRoot + /cabal.project;
#     in
#     if builtins.pathExists fp then
#       fp
#     else
#       throw ''
#         Invalid value `${repoRoot}` for configuration field `repoRoot`: cabal.project not found.
#         A cabal.project file must be created in the location specified by 'repoRoot'.
#       '';

#   readTheDocsFolder =
#     if builtins.hasAttr "readTheDocsFolder" c ? then
#       if builtins.pathExists fp then
#       c.readTheDocsFolder
#     else
#       throw ''
#         Invalid value `${readTheDocsFolder}` for configuration field 'readTheDocsFolder': path does not exist. 
#         Please provide a path to an existing folder.
#         Leave `readTheDocsFolder` unset if this project does not integrate readthedocs.
#       ''
#     else
#     null;

#   haskellCompilers =
#     if c ? haskellCompilers then
#       if l.length c.haskellCompilers == 0 then
#         throw ''
#           Invalid value for configuration field 'haskellCompilers': empty list.
#           Please specify at least one compiler.
#           Available options are: ["ghc8107", "ghc924"].
#           The default compiler will be first item in the list.
#           To override this set `defaultHaskellCompiler` manually.
#         ''
#       else
#         l.forEach c.haskellCompilers (checkEnum "haskellCompilers" [ "ghc8107" "ghc924" ])
#     else
#       throw ''
#         Configuration field `haskellCompilers` not set.
#         Please provide a list of supported compilers.
#         Available options are: ["ghc8107", "ghc924"].
#         The default compiler will be first item in the list.
#         To override this set `defaultHaskellCompiler` manually.
#       '';

#   haskellDefaultCompiler =
#     if c ? defaultHaskellCompiler then
#       checkEnum "defaultHaskellCompiler" haskellCompilers c.defaultHaskellCompiler
#     else
#       traceDefault "defaultHaskellCompiler" (l.head haskellCompilers);
#   x = 1;
# in 
#   unverified-config
