{ inputs, systemized-inputs, config, pkgs, l, haskell-toolchains }:

ghc:

let
  haskell-toolchain = haskell-toolchains.${ghc};

  makeFlake = { enableProfiling }:
    let
      haskell-project = import ./haskell-project.nix
        {
          inherit inputs systemized-inputs config pkgs ghc enableProfiling;
          deferPluginErrors = false;
        };

      haskell-project-shell = import ./haskell-project-shell.nix
        { inherit haskell-project haskell-toolchain; };

      haskell-project-flake = import ./haskell-project-flake.nix
        { inherit pkgs haskell-project haskell-project-shell; };
    in
    haskell-project-flake;

  profiled-flake = makeFlake { enableProfiling = true; };

  unprofiled-flake = makeFlake { enableProfiling = false; };

  prefixed-profiled-flake = l.nestAttrs profiled-flake [ "${ghc}" ];

  prefixed-unprofiled-flake = l.nestAttrs unprofiled-flake [ "profiled" "${ghc}" ];

  prefixed-flakes = [ prefixed-profiled-flake prefixed-unprofiled-flake ];

  final-flake = l.recursiveUpdateMany prefixed-flakes;
in
final-flake
