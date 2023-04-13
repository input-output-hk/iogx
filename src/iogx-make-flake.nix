iogx-inputs:

user-inputs:

unvalidated-config:

let
  systemized-inputs = import ./iogx-merge-inputs.nix
    { inherit iogx-inputs user-inputs; };

  l = import ./lib.nix
    { inherit systemized-inputs; };

  config = import ./iogx-validate-config.nix { inherit unvalidated-config l; };

  makeOutputsForSystem = system:
    let
      inputs = systemized-inputs.nosys.lib.deSys system systemized-inputs;

      pkgs = import ./iogx-pkgs.nix
        { inherit inputs config system; };

      base-toolchain = import ./iogx-base-toolchain.nix
        { inherit inputs config pkgs; };

      makeHaskellToolchain = import ./iogx-haskell-toolchain.nix
        { inherit inputs systemized-inputs config pkgs l base-toolchain; };

      haskell-toolchains =
        l.genAttrs config.haskell.compilers makeHaskellToolchain;

      makeHaskellProjectFlake = import ./iogx-haskell-project-flake.nix
        { inherit inputs systemized-inputs config pkgs l haskell-toolchains; };

      haskell-project-flake =
        l.recursiveUpdateMany (map makeHaskellProjectFlake config.haskell.compilers);

      devShells = import ./iogx-devshells.nix
        { inherit inputs systemized-inputs config pkgs l haskell-project-flake base-toolchain; };

      packages = { };

      outputs = l.recursiveUpdateMany [
        # We `removeAttrs` because we want to use the devShells below
        (removeAttrs haskell-project-flake [ "devShell" "devShells" ])
        { inherit devShells; }
        { inherit packages; }
        { inherit l; }
        # NOTE: calling config function
        # TODO ensure that the returned attrs does not contain hydraJobs?
        (config.perSystemOutputs { inherit inputs systemized-inputs pkgs config; })
      ];

      hydraJobs = import ./iogx-configure-hydra-jobs.nix
        { inherit config outputs l; };

      final-outputs = outputs // { inherit hydraJobs; ciJobs = hydraJobs; };
    in
    final-outputs;

  perSystemOutputs = systemized-inputs.flake-utils.lib.eachSystem config.systems makeOutputsForSystem;

  # NOTE: calling config function
  systemIndependentOutputs = config.systemIndependentOutputs { inherit systemized-inputs; };

  finalFlake = perSystemOutputs // systemIndependentOutputs;

in

finalFlake

