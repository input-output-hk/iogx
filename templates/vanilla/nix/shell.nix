{ repoRoot, inputs, pkgs, lib, system }:

# Docs for mkShell: https://github.com/input-output-hk/iogx/blob/main/doc/api.md#mkshell
lib.iogx.mkShell {

  name = "nix-shell";

  # prompt = null;

  # welcomeMessage = null;

  # packages = [];

  # scripts = {};

  # env = {};

  # shellHook = "";

  tools = {
    # haskellCompilerVersion = "ghc8107";
    # cabal-fmt = null;
    # cabal-install = null;
    # haskell-language-server = null;
    # haskell-language-server-wrapper = null;
    # fourmolu = null;
    # hlint = null;
    # stylish-haskell = null;
    # ghcid = null;
    # shellcheck = null;
    # prettier = null;
    # editorconfig-checker = null;
    # nixpkgs-fmt = null;
    # optipng = null;
    # purs-tidy = null;
  };

  # preCommit = {
  #   cabal-fmt.enable = false;
  #   cabal-fmt.extraOptions = "";
  #   stylish-haskell.enable = false;
  #   stylish-haskell.extraOptions = "";
  #   fourmolu.enable = false;
  #   fourmolu.extraOptions = "";
  #   hlint.enable = false;
  #   hlint.extraOptions = "";
  #   shellcheck.enable = false;
  #   shellcheck.extraOptions = "";
  #   prettier.enable = false;
  #   prettier.extraOptions = "";
  #   editorconfig-checker.enable = false;
  #   editorconfig-checker.extraOptions = "";
  #   nixpkgs-fmt.enable = false;
  #   nixpkgs-fmt.extraOptions = "";
  #   optipng.enable = false;
  #   optipng.extraOptions = "";
  #   purs-tidy.enable = false;
  #   purs-tidy.extraOptions = "";
  # };
}
 