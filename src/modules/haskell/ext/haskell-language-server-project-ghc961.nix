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
    constraints: stylish-haskell==0.14.2.0, hlint==3.4.1
  '';

  src = l.fetchTarball {
    url = https://github.com/haskell/haskell-language-server/archive/refs/tags/1.10.0.0.tar.gz;
    sha256 = "sha256:1ivqj503al44nnilmpqd916ds5cl7hcxy4jm94ahi8y13v9p8r7y";
  };

  compiler-nix-name = "ghc961";

  sha256map = {
    "https://github.com/pepeiborra/ekg-json"."7a0af7a8fd38045fd15fb13445bdcc7085325460" = "sha256-fVwKxGgM0S4Kv/4egVAAiAjV7QB5PBqMVMCfsv7otIQ="; # editorconfig-checker-disable-line
  };

  modules = [{
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005
    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;
  }];
}

