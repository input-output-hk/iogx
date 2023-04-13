{ inputs, systemized-inputs, config, pkgs, l, haskell-project-flake, base-toolchain }:

let

  makeDevenvShell = modules: haskell-project-shell:
    let
      # NOTE: calling config function
      user-devenv-module = config.devenvModule { inherit inputs systemized-inputs config pkgs; };

      standard-devenv-module = import ./standard-devenv-module.nix
        { inherit pkgs haskell-project-shell base-toolchain; };
    in
    inputs.devenv.lib.mkShell {
      inherit pkgs inputs;
      modules = [ user-devenv-module standard-devenv-module ];
    };

  unprefixed-shell =
    {
      default = makeDevenvShell haskell-project-flake.devShells.default;
    };

  makePrefixedShells = ghc:
    {
      "${ghc}" = makeDevenvShell haskell-project-flake.devShells.${ghc}.default;
      profiled.${ghc} = makeDevenvShell haskell-project-flake.devShells.profiled.${ghc}.default;
    };

  allPrefixedShells = map makePrefixedShells config.haskell.compilers;

  allShells = [ unprefixed-shell ] ++ allPrefixedShells;
in
l.recursiveUpdateMany allShells
