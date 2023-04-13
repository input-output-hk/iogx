{ pkgs, inputs, ghc }:

pkgs.haskell-nix.cabalProject' {

  # See https://github.com/haskell/haskell-language-server/issues/411.
  # We want to use stylish-haskell, hlint, and implicit-hie as standalone tools *and* through HLS. But we need to have consistent versions in both
  # cases, otherwise e.g. you could format the code in HLS and then have the CI complain that it's wrong.
  # The solution we use here is to:
  # a) Where we care (mostly just formatters), constrain the versions of tools which HLS uses explicitly
  # b) pull out the tools themselves from the HLS project so we can use them elsewhere
  cabalProjectLocal = ''
    constraints: stylish-haskell==0.12.2.0, hlint==3.2.7
    allow-newer: hls-stylish-haskell-plugin:stylish-haskell
  '';

  src = inputs.haskell-language-server-1_3_0_0;

  compiler-nix-name = ghc;

  index-state = "2023-03-05T00:00:00Z";

  sha256map = {
    "https://github.com/hsyl20/ghc-api-compat"."8fee87eac97a538dbe81ff1ab18cff10f2f9fa15" = "16bibb7f3s2sxdvdy2mq6w1nj1lc8zhms54lwmj17ijhvjys29vg";
    "https://github.com/haskell/lsp.git"."ef59c28b41ed4c5775f0ab0c1e985839359cec96" = "1whcgw4hhn2aplrpy9w8q6rafwy7znnp0rczgr6py15fqyw2fwb5";
  };

  modules = [{
    # Workaround for https://github.com/haskell/haskell-language-server/issues/1160
    packages.haskell-language-server.patches = pkgs.lib.mkIf pkgs.stdenv.isDarwin [ ./haskell-language-server-project-1.3.0.0.patch ];
    # See https://github.com/haskell/haskell-language-server/pull/1382#issuecomment-780472005
    packages.ghcide.flags.ghc-patched-unboxed-bytecode = true;
  }];
}
