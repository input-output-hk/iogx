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

  antaeus-module = { config, ... }: {
    packages = {
      # Things that need plutus-tx-plugin
      freer-extras.package.buildable = !isCross;
      cardano-node-emulator.package.buildable = !isCross;
      cardano-streaming.package.buildable = !isCross;
      antaeus-e2e-tests.package.buildable = !isCross;
      # These need R
      plutus-core.components.benchmarks.cost-model-test.buildable = lib.mkForce (!isCross);
      plutus-core.components.benchmarks.update-cost-model.buildable = lib.mkForce (!isCross);

      plutus-pab-executables.components.tests.plutus-pab-test-full-long-running.buildable = lib.mkForce (!isDarwin);

      antaeus-e2e-tests.doHaddock = deferPluginErrors;
      antaeus-e2e-tests.flags.defer-plugin-errors = deferPluginErrors;

      # The lines `export CARDANO_NODE=...` and `export CARDANO_CLI=...`
      # is necessary to prevent the error
      # `../dist-newstyle/cache/plan.json: openBinaryFile: does not exist (No such file or directory)`.
      # See https://github.com/input-output-hk/cardano-node/issues/4194.
      #
      # The line 'export CARDANO_NODE_SRC=...' is used to specify the
      # root folder used to fetch the `configuration.yaml` file (in
      # antaeus, it's currently in the
      # `configuration/defaults/byron-mainnet` directory.
      # Else, we'll get the error
      # `/nix/store/ls0ky8x6zi3fkxrv7n4vs4x9czcqh1pb-antaeus/antaeus/test/configuration.yaml: openFile: does not exist (No such file or directory)`
      antaeus-e2e-tests.preCheck = "
        export CARDANO_CLI=${config.hsPkgs.cardano-cli.components.exes.cardano-cli}/bin/cardano-cli${pkgs.stdenv.hostPlatform.extensions.executable}
        export CARDANO_NODE=${config.hsPkgs.cardano-node.components.exes.cardano-node}/bin/cardano-node${pkgs.stdenv.hostPlatform.extensions.executable}
        export CARDANO_NODE_SRC=${config.src}
      ";

      # FIXME: Haddock mysteriously gives a spurious missing-home-modules warning
      plutus-tx-plugin.doHaddock = false;

      # Relies on cabal-doctest, just turn it off in the Nix build
      prettyprinter-configurable.components.tests.prettyprinter-configurable-doctest.buildable = lib.mkForce false;

      # Broken due to warnings, unclear why the setting that fixes this for the build doesn't work here.
      iohk-monitoring.doHaddock = false;
      cardano-wallet.doHaddock = false;

      # Werror everything. This is a pain, see https://github.com/input-output-hk/haskell.nix/issues/519
      cardano-streaming.ghcOptions = [ "-Werror" ];
      antaeus-e2e-tests.ghcOptions = [ "-Werror" ];
      pab-blockfrost.ghcOptions = [ "-Werror" ];

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

  sha256map = {
    "https://github.com/input-output-hk/cardano-addresses"."b7273a5d3c21f1a003595ebf1e1f79c28cd72513" = "129r5kyiw10n2021bkdvnr270aiiwyq58h472d151ph0r7wpslgp";
    "https://github.com/input-output-hk/cardano-config"."1646e9167fab36c0bff82317743b96efa2d3adaa" = "sha256-TNbpnR7llUgBN2WY7CryMxNVupBIUH01h1hRNHoxboY=";
    "https://github.com/input-output-hk/cardano-ledger"."da3e9ae10cf9ef0b805a046c84745f06643583c2" = "sha256-3VUZKkLu1R43GUk9IwgsGQ55O0rnu8NrCkFX9gqA4ck=";
    "https://github.com/input-output-hk/cardano-wallet"."18a931648550246695c790578d4a55ee2f10463e" = "0i40hp1mdbljjcj4pn3n6zahblkb2jmpm8l4wnb36bya1pzf66fx";
    "https://github.com/sevanspowell/hw-aeson"."b5ef03a7d7443fcd6217ed88c335f0c411a05408" = "1dwx90wqavdl4d0npbzbxyh2pzi9zs1qz7nvsrb3n1cm2xbv4i5z";
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

  modules = [ antaeus-module ] ++ pkgs.lib.optional enableProfiling { enableProfiling = true; };
})
