{ pkgs, l, ... }:

pkgs.haskell-nix.cabalProject' {

  # Benchmarks are only buildable with ghc < 9.5
  configureArgs = "--disable-benchmarks";

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
    constraints: stylish-haskell==0.14.5.0, hlint==3.6.1
  '';

  src = pkgs.fetchFromGitHub {
    owner = "haskell";
    repo = "haskell-language-server";
    rev = "2.1.0.0";
    sha256 = "sha256-/mR00x7BowgVSVUS3xk8lBXdTEgN30qjtYRQNUCReMc=";
  };

  compiler-nix-name = "ghc962";

  modules = [{
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005
    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;
  }];
}

