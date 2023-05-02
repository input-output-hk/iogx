{ inputs # Desystemized merged inputs 
, systemized-inputs # Non-desystemized merged inputs
, flakeopts # iogx config passed to mkFlake
, pkgs # Desystemized nixpkgs (NEVER use systemized-inputs.nixpkgs.legacyPackages!)
, ghc # Current compiler
, deferPluginErrors # For Haddock generation
, enableProfiling
}:

let
  lib = pkgs.lib;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isCross = pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform;

  marconi-module = { config, ... }: {
    packages = {
      # Things that need plutus-tx-plugin
      cardano-node-emulator.package.buildable = !isCross;
      cardano-streaming.package.buildable = !isCross;
      marconi-chain-index.package.buildable = !isCross;
      marconi-core.package.buildable = !isCross;
      marconi-sidechain.package.buildable = !isCross;
      # These need R
      plutus-core.components.benchmarks.cost-model-test.buildable = lib.mkForce (!isCross);
      plutus-core.components.benchmarks.update-cost-model.buildable = lib.mkForce (!isCross);

      marconi-core.doHaddock = deferPluginErrors;
      marconi-core.flags.defer-plugin-errors = deferPluginErrors;

      marconi-chain-index.doHaddock = deferPluginErrors;
      marconi-chain-index.flags.defer-plugin-errors = deferPluginErrors;

      # The lines `export CARDANO_NODE=...` and `export CARDANO_CLI=...`
      # is necessary to prevent the error
      # `../dist-newstyle/cache/plan.json: openBinaryFile: does not exist (No such file or directory)`.
      # See https://github.com/input-output-hk/cardano-node/issues/4194.
      #
      # The line 'export CARDANO_NODE_SRC=...' is used to specify the
      # root folder used to fetch the `configuration.yaml` file (in
      # marconi, it's currently in the
      # `configuration/defaults/byron-mainnet` directory.
      # Else, we'll get the error
      # `/nix/store/ls0ky8x6zi3fkxrv7n4vs4x9czcqh1pb-marconi/marconi/test/configuration.yaml: openFile: does not exist (No such file or directory)`
      marconi-chain-index.preCheck = "
        export CARDANO_CLI=${config.hsPkgs.cardano-cli.components.exes.cardano-cli}/bin/cardano-cli${pkgs.stdenv.hostPlatform.extensions.executable}
        export CARDANO_NODE=${config.hsPkgs.cardano-node.components.exes.cardano-node}/bin/cardano-node${pkgs.stdenv.hostPlatform.extensions.executable}
        export CARDANO_NODE_SRC=${flakeopts.repoRoot}
      ";

      marconi-sidechain.doHaddock = deferPluginErrors;
      marconi-sidechain.flags.defer-plugin-errors = deferPluginErrors;
      # FIXME: Haddock mysteriously gives a spurious missing-home-modules warning
      plutus-tx-plugin.doHaddock = false;

      # Relies on cabal-doctest, just turn it off in the Nix build
      prettyprinter-configurable.components.tests.prettyprinter-configurable-doctest.buildable = lib.mkForce false;

      # Broken due to warnings, unclear why the setting that fixes this for the build doesn't work here.
      iohk-monitoring.doHaddock = false;
      cardano-wallet.doHaddock = false;

      # Werror everything. This is a pain, see https://github.com/input-output-hk/haskell.nix/issues/519
      cardano-streaming.ghcOptions = [ "-Werror" ];
      marconi-chain-index.ghcOptions = [ "-Werror" ];
      marconi-core.ghcOptions = [ "-Werror" ];
      marconi-sidechain.ghcOptions = [ "-Werror" ];

      # Honestly not sure why we need this, it has a mysterious unused dependency on "m"
      # This will go away when we upgrade nixpkgs and things use ieee754 anyway.
      ieee.components.library.libs = lib.mkForce [ ];

      # See https://github.com/input-output-hk/iohk-nix/pull/488
      cardano-crypto-praos.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf ] ];
      cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 ] ];
    };
  };
in
pkgs.haskell-nix.cabalProject' (_: {

  compiler-nix-name = ghc;

  src = flakeopts.repoRoot;

  shell.withHoogle = false;

  sha256map = {
    "https://github.com/input-output-hk/cardano-node"."a158a679690ed8b003ee06e1216ac8acd5ab823d" = "sha256-uY7wPyCgKuIZcGu0+vGacjGw2kox8H5ZsVGsfTNtU0c=";
  };

  inputMap = {
    "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
  };

  # Configuration settings needed for cabal configure to work when cross compiling
  # for windows. We can't use `modules` for these as `modules` are only applied
  # after cabal has been configured.
  cabalProjectLocal = lib.optionalString pkgs.stdenv.hostPlatform.isWindows ''
    -- When cross compiling for windows we don't have a `ghc` package, so use
    -- the `plutus-ghc-stub` package instead.
    package plutus-tx-plugin
      flags: +use-ghc-stub

    -- Exlcude test that use `doctest`.  They will not work for windows
    -- cross compilation and `cabal` will not be able to make a plan.
    package prettyprinter-configurable
      tests: False
  '';

  modules = [ marconi-module ] ++ pkgs.lib.optional enableProfiling { enableProfiling = true; };
})
