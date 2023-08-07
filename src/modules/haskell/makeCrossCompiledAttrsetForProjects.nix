{ src, iogx-inputs, iogx-interface, inputs, inputs', pkgs, l, ... }:

projects: # The haskell.nix projects with the meta field, prefixed by ghc config

let

  haskell = iogx-interface."haskell.nix".load { inherit inputs inputs' pkgs; };


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
      let projects' = l.attrValues (removeAttrs projects [ "default" "profiled" ]);
      in l.mapAttrValues makeCrossFlakeForProject projects';
    else
      { };

in

{ x86_64-linux.mingwW64 = cross-compiled-projects; }
