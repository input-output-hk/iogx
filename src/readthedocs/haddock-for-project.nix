{ inputs, inputs', pkgs, iogx-config, src, ... }:

ghc:

let
  haskell-lib = pkgs.haskell-nix.haskellLib;

  project-with-haddock = iogx-config.haskellProjectFile {
    inherit inputs inputs' iogx-config pkgs ghc;
    enableProfiling = false;
    deferPluginErrors = true;
  };

  hsPkgs = project-with-haddock.hsPkgs;

  toHaddock =
    haskell-lib.collectComponents' "library" (
      haskell-lib.selectProjectPackages hsPkgs //
      (iogx-config.readTheDocs.haddockExtraProjectPackages hsPkgs)
    );

  combined-haddock = src.readthedocs.haddock-combine {
    ghc = project-with-haddock.pkg-set.config.ghc.package;
    hspkgs = builtins.attrValues toHaddock;
    prologue = pkgs.writeTextFile {
      name = "prologue";
      text = iogx-config.readTheDocs.haddockPrologue;
    };
  };
in
combined-haddock
