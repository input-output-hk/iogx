validators: with validators;

{
  supportedCompilers.type = nonempty-enum-list [ "ghc8107" "ghc927" "ghc928" ];

  defaultCompiler.type = enum [ "ghc8107" "ghc927" "ghc928" ];
  defaultCompiler.default = conf: builtins.head conf.supportedCompilers;

  enableCrossCompilation.type = bool;
  enableCrossCompilation.default = false;

  cabalProjectFolder.type = nonempty-string; # TODO add to docs
  cabalProjectFolder.default = ".";

  defaultChangelogPackages.type = list-of string;
  defaultChangelogPackages.default = [ ];

  projectPackagesWithHaddock.type = list-of string; # TODO add to docs
  projectPackagesWithHaddock.default = [ ];

  combinedHaddockPrologue.type = string; # TODO add to docs
  combinedHaddockPrologue.default = "";
}
 