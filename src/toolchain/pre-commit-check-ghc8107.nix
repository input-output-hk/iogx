{ inputs, pkgs, iogx, flakeopts, ... }:

inputs.pre-commit-hooks-nix.lib.${pkgs.stdenv.system}.run {

  src = pkgs.lib.cleanSource flakeopts.repoRoot;

  tools = {
    shellcheck = pkgs.shellcheck;
    stylish-haskell = iogx.toolchain.haskell-toolchain-ghc8107.stylish-haskell;
    nixpkgs-fmt = iogx.toolchain.nixpkgs-fmt;
    cabal-fmt = iogx.toolchain.cabal-fmt;
  };

  hooks = {
    stylish-haskell.enable = true;
    cabal-fmt.enable = true;
    shellcheck.enable = true;

    prettier = {
      enable = true;
      types_or = [ "javascript" "css" "html" ];
    };

    editorconfig-checker = pkgs.lib.mkForce {
      enable = false; # TODO [devx] enable
      entry = "${pkgs.editorconfig-checker}/bin/editorconfig-checker";
    };

    nixpkgs-fmt = {
      enable = true;
      # While nixpkgs-fmt does exclude patterns specified in `.ignore` this
      # does not appear to work inside the hook. For now we have to thus
      # maintain excludes here *and* in `./.ignore` and *keep them in sync*.
      excludes = [
        ".*/spago-packages.nix$"
        ".*/packages.nix$"
      ];
    };

    png-optimization = {
      enable = true;
      name = "png-optimization";
      description = "Ensure that PNG files are optimized";
      entry = "${pkgs.optipng}/bin/optipng";
      files = "\\.png$";
    };
  };
}
