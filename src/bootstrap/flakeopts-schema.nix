{ l, libnixschema }:

let
  V = libnixschema.validators;

  schema = {
    inputs = {
      validator = V.attrset;
      optional = false;
    };

    debug = {
      validator = V.boolean;
      optional = true;
      default = _: true;
    };

    repoRoot = {
      validator = V.dir-with-file "cabal.project";
      optional = false;
    };

    flakeOutputsPrefix = {
      validator = V.string;
      optional = true;
      default = _: "";
    };

    systems = {
      validator = V.nonempty-enum-list V.string [ "x86_64-linux" "x86_64-darwin" ];
      optional = true;
      default = _: [ "x86_64-linux" "x86_64-darwin" ];
    };

    haskellCompilers = {
      validator = V.nonempty-enum-list V.string [ "ghc8107" "ghc925" ];
      optional = true;
      default = _: [ "ghc8107" ];
    };

    defaultHaskellCompiler = {
      validator = V.enum V.string [ "ghc8107" "ghc925" ];
      optional = true;
      default = spec: l.head spec.haskellCompilers;
    };

    haskellCrossSystem = {
      validator = V.null-or (V.enum V.string [ "x86_64-linux" "x86_64-darwin" ]);
      optional = true;
      default = _: "";
    };

    haskellProjectFile = {
      validator = V.path-exists;
      optional = true;
      # TODO assert exists
      default = spec: spec.repoRoot + "/nix/haskell-project.nix";
    };

    perSystemOutputsFile = {
      validator = V.null-or V.path-exists;
      optional = true;
      default = spec: l.validPathOrNull (spec.repoRoot + "/nix/per-system-outputs.nix");
    };

    shellName = {
      validator = V.nonempty-string;
      optional = true;
      default = _: "[unnamed]";
    };

    shellPrompt = {
      validator = V.nonempty-string;
      optional = true;
      default = spec: "\n\\[\\033[1;32m\\][${spec.shellName}:\\w]\\$\\[\\033[0m\\] ";
    };

    shellWelcomeMessage = {
      validator = V.nonempty-string;
      optional = true;
      default = spec: "🤟 \\033[1;31mWelcome to ${spec.shellName}\\033[0m 🤟";
    };

    shellModuleFile = {
      validator = V.null-or V.path-exists;
      optional = true;
      default = spec: l.validPathOrNull (spec.repoRoot + "/nix/shell-module.nix");
    };

    includeHydraJobs = {
      validator = V.boolean;
      optional = true;
      default = _: true;
    };

    excludeProfiledHaskellFromHydraJobs = {
      validator = V.boolean;
      optional = true;
      default = _: true;
    };

    blacklistedHydraJobs = {
      validator = V.list V.string;
      optional = true;
      default = _: [ ];
    };

    enableHydraPreCommitCheck = {
      validator = V.boolean;
      optional = true;
      default = _: true;
    };

    includeReadTheDocsSite = {
      validator = V.boolean;
      optional = true;
      default = _: false;
    };

    readTheDocsSiteDir = {
      validator = V.null-or V.path-exists; # TODO create file-exists and dir-exists
      optional = true;
      default = spec: l.validPathOrNull (spec.repoRoot + "/doc/read-the-docs-site");
    };

    readTheDocsHaddockPrologue = {
      validator = V.string;
      optional = true;
      default = _: "";
    };

    readTheDocsExtraHaddockPackages = {
      validator = V.function;
      optional = true;
      default = _: _: { };
    };
  };
in
schema
