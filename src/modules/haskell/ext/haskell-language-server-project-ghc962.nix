{ iogx-inputs, pkgs, l, ... }:

pkgs.haskell-nix.cabalProject' {

  cabalProjectLocal = ''
    package shake-bench
      buildable: False
    benchmarks: False
  '';

  # constraints: stylish-haskell==0.14.2.0, hlint==3.4.1

  src = l.fetchTarball {
    url = https://github.com/haskell/haskell-language-server/releases/download/2.1.0.0/haskell-language-server-2.1.0.0-src.tar.gz;
    sha256 = "sha256:1ivqj503al44nnilmpqd916ds5cl7hcxy4jm94ahi8y13v9p8r7y";
  };

  compiler-nix-name = "ghc962";

  modules = [{
    # packages.shake-bench.buildable = l.mkForce false;
    # packages.haskell-language-server.buildable = l.mkForce false;
    # packages.haskell-language-server.components.benchmarks.benchmark.buildable = l.mkForce false;
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005

    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;
  }];
}

