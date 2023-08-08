{ src, iogx-inputs, nix, iogx-interface, inputs, inputs', pkgs, l, system, ... }:

projects: # The haskell.nix projects with the meta field, prefixed by ghc config

let

  haskell = iogx-interface."haskell.nix".load
    { inherit nix inputs inputs' pkgs l system; };


  makeCrossFlakeForProject = project:
    let
      haskellLib = pkgs.haskell-nix.haskellLib;
      project-cross = project.projectCross.mingwW64;
      hsPkgs = haskellLib.selectProjectPackages project-cross.hsPkgs;
    in
    {
      exes = haskellLib.collectComponents' "exes" hsPkgs;
      tests = haskellLib.collectComponents' "tests" hsPkgs;
      benchmarks = haskellLib.collectComponents' "benchmarks" hsPkgs;
      libraries = haskellLib.collectComponents' "library" hsPkgs;
      sublibs = haskellLib.collectComponents' "sublibs" hsPkgs;
      checks = haskellLib.collectChecks' hsPkgs;
      roots = project-cross.roots;
      plan-nix = project-cross.plan-nix;
    };


  should-cross-compile =
    haskell.enableCrossCompilation && pkgs.stdenv.system == "x86_64-linux";


  cross-compiled-projects =
    if should-cross-compile then
      { mingwW64 = l.mapAttrValues makeCrossFlakeForProject projects; }
    else
      { };

in

cross-compiled-projects
