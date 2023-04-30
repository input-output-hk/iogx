{ inputs, systemized-inputs, pkgs, flakeopts, iogx, ... }:

ghc:

let
  haskell-lib = pkgs.haskell-nix.haskellLib;

  project-with-haddock = flakeopts.haskellProjectFile {
    inherit inputs systemized-inputs flakeopts pkgs ghc;
    enableProfiling = false;
    deferPluginErrors = true;
  };

  hsPkgs = project-with-haddock.hsPkgs;

  toHaddock =
    haskell-lib.collectComponents' "library" (
      haskell-lib.selectProjectPackages hsPkgs //
      (flakeopts.readTheDocs.haddockExtraProjectPackages hsPkgs)
    );

  combined-haddock = iogx.readthedocs.haddock-combine {
    ghc = project-with-haddock.pkg-set.config.ghc.package;
    hspkgs = builtins.attrValues toHaddock;
    prologue = pkgs.writeTextFile {
      name = "prologue";
      text = flakeopts.readTheDocs.haddockPrologue;
    };
  };
in
combined-haddock
