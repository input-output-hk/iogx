{ inputs, systemized-inputs, config, pkgs, ghc, deferPluginErrors, enableProfiling }:

let
  shared-iohk-module = _: {

    packages =
      let
        lib = pkgs.lib;
        mkIfDarwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin;
        isCross = pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform;
        rPackages = with pkgs.rPackages; [ R tidyverse dplyr stringr MASS plotly shiny shinyjs purrr ];
      in
      {
        # [devx] this fails...
        http2.doHaddock = false;

        # Things that need plutus-tx-plugin
        plutus-ledger.package.buildable = !isCross;
        plutus-tx-plugin.package.buildable = !isCross;

        # These libraries rely on a TemplateHaskell splice that requires
        # git to be in the path at build time. This only seems to affect
        # Darwin builds, and including them on Linux breaks lorri, so we
        # only add these options when building on Darwin.
        cardano-config.components.library.build-tools = mkIfDarwin [ pkgs.buildPackages.buildPackages.gitReallyMinimal ];

        plutus-contract.doHaddock = deferPluginErrors;
        plutus-contract.flags.defer-plugin-errors = deferPluginErrors;

        plutus-use-cases.doHaddock = deferPluginErrors;
        plutus-use-cases.flags.defer-plugin-errors = deferPluginErrors;

        plutus-ledger.doHaddock = deferPluginErrors;
        plutus-ledger.flags.defer-plugin-errors = deferPluginErrors;

        # Packages we just don't want docs for
        plutus-benchmark.doHaddock = false;
        # FIXME: Haddock mysteriously gives a spurious missing-home-modules warning
        plutus-tx-plugin.doHaddock = false;
        plutus-script-utils.doHaddock = false;

        # Relies on cabal-doctest, just turn it off in the Nix build
        prettyprinter-configurable.components.tests.prettyprinter-configurable-doctest.buildable = lib.mkForce false;

        plutus-core.components.benchmarks.update-cost-model = {
          build-tools = rPackages;
          # Seems to be broken on darwin for some reason
          platforms = lib.platforms.linux;
        };

        plutus-core.components.benchmarks.cost-model-test = {
          build-tools = rPackages;
          # Seems to be broken on darwin for some reason
          platforms = lib.platforms.linux;
        };

        # Broken due to warnings, unclear why the setting that fixes this for the build doesn't work here.
        iohk-monitoring.doHaddock = false;

        # External package settings
        inline-r.ghcOptions = [ "-XStandaloneKindSignatures" ];

        # Honestly not sure why we need this, it has a mysterious unused dependency on "m"
        # This will go away when we upgrade nixpkgs and things use ieee754 anyway.
        ieee.components.library.libs = lib.mkForce [ ];

        # See https://github.com/input-output-hk/iohk-nix/pull/488
        cardano-crypto-praos.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 ] ];
        cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf pkgs.secp256k1 ] ];

        # hpack fails due to modified cabal file, can remove when we bump to 3.12.0
        cardano-addresses.cabal-generator = lib.mkForce null;
        cardano-addresses-cli.cabal-generator = lib.mkForce null;
      };
  };
in
pkgs.haskell-nix.cabalProject' ({ pkgs, ... }: {

  compiler-nix-name = ghc;

  src = config.repoRoot;

  inputMap = {
    "https://input-output-hk.github.io/cardano-haskell-packages" = inputs.CHaP;
  };

  modules =
    # NOTE: calling config function
    config.haskell.projectModules { inherit inputs systemized-inputs config pkgs ghc deferPluginErrors; } ++
    [ shared-iohk-module ] ++
    pkgs.lib.optional enableProfiling { enableProfiling = true; };
})
