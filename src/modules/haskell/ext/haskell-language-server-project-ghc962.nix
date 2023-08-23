{ iogx-inputs, pkgs, l, ... }:

pkgs.haskell-nix.cabalProject' {

  # See https://github.com/haskell/haskell-language-server/issues/411.
  # We want to use stylish-haskell, hlint, and implicit-hie as standalone tools
  # *and* through HLS. But we need to have consistent versions in both cases,
  # otherwise e.g. you could format the code in HLS and then have the CI
  # complain that it's wrong
  #
  # The solution we use here is to:
  # a) Where we care (mostly just formatters), constrain the versions of
  #    tools which HLS uses explicitly
  # b) Pull out the tools themselves from the HLS project so we can use
  #    them elsewhere
  cabalProjectLocal = ''
    package shake-bench
      buildable: False
    benchmarks: Falses
  '';
  # constraints: stylish-haskell==0.14.2.0, hlint==3.4.1

  src = l.fetchTarball {
    url = https://github.com/haskell/haskell-language-server/releases/download/2.1.0.0/haskell-language-server-2.1.0.0-src.tar.gz;
    sha256 = "sha256:1ivqj503al44nnilmpqd916ds5cl7hcxy4jm94ahi8y13v9p8r7y";
  };

  # Cannot build with 9.6.2 because shake-bench.cabal has this constraint:
  # if impl(ghc >= 9.5)
  #   buildable: False
  compiler-nix-name = "ghc962";

  modules = [{
    # packages.shake-bench.buildable = false;
    # packages.shake-bench.buildable = false;
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005
    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;
  }];
}

