{ unvalidated-flakeopts, l }:
let
  c = unvalidated-flakeopts;

  findFile = path: default:
    if l.hasAttrByPath path c then
      l.attrByPath path c
    else if l.pathExists (c.nixFolder + "/${default}/default.nix") then
      import (c.nixFolder + "/${default}/default.nix")
    else if l.pathExists (c.nixFolder + "/${default}.nix") then
      import (c.nixFolder + "/${default}.nix")
    else
      (_: { });

in
rec {
  systems = c.systems;

  repoRoot = c.repoRoot;
  nixFolder = c.nixFolder; # TODO make default somehow

  shellPrompt =
    if c ? shellPrompt then
      c.shellPrompt
    else
      "\n\\[\\033[1;32m\\][${shellName}:\\w]\\$\\[\\033[0m\\] ";

  shellName =
    if c ? shellName then
      c.shellName
    else
      "nix-shell";

  # repoRoot =
  #   if c ? repoRoot then
  #     c.repoRoot
  #   else
  #     outPath;

  readTheDocsFolder =
    if c ? readTheDocsFolder then
      c.readTheDocsFolder
    else
      null;

  systemIndependentOutputs = findFile [ "systemIndependentOutputs" ] "system-independent-outputs";

  perSystemOutputs = findFile [ "perSystemOutputs" ] "per-system-outputs";

  defaultShell = findFile [ "defaultShell" ] "default-shell";

  overlays = findFile [ "overlays" ] "overlays";

  haskell = rec {

    crossSystem =
      if c ? haskell.crossSystem then
        c.haskell.crossSystem
      else
        null;

    compilers = c.haskell.compilers;

    project = findFile [ "haskell" "project" ] "haskell-project";

    defaultCompiler =
      if c ? haskell.defaultCompiler then
        c.haskell.defaultCompiler
      else
        l.head compilers;
  };

  hydraJobs = rec {

    blacklistedDerivations =
      if c ? hydraJobs.blacklistedDerivations then
        c.hydraJobs.blacklistedDerivations
      else
        [ ];

    excludeProfiledHaskell =
      if c ? hydraJobs.excludeProfiledHaskell then
        c.hydraJobs.excludeProfiledHaskell
      else
        true;
  };
}

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
#     if c ? haskell.compilers then
#       if l.length c.haskell.compilers == 0 then
#         throw ''
#           Invalid value for configuration field 'haskell.compilers': empty list.
#           Please specify at least one compiler.
#           Available options are: ["ghc8107", "ghc924"].
#           The default compiler will be first item in the list.
#           To override this set `haskell.defaultCompiler` manually.
#         ''
#       else
#         l.forEach c.haskell.compilers (checkEnum "haskell.compilers" [ "ghc8107" "ghc924" ])
#     else
#       throw ''
#         Configuration field `haskell.compilers` not set.
#         Please provide a list of supported compilers.
#         Available options are: ["ghc8107", "ghc924"].
#         The default compiler will be first item in the list.
#         To override this set `haskell.defaultCompiler` manually.
#       '';

#   haskellDefaultCompiler =
#     if c ? haskell.defaultCompiler then
#       checkEnum "haskell.defaultCompiler" haskellCompilers c.haskell.defaultCompiler
#     else
#       traceDefault "haskell.defaultCompiler" (l.head haskellCompilers);
#   x = 1;
# in 
#   unverified-config
