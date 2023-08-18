{ src, iogx-inputs, repoRoot, iogxRepoRoot, iogx-interface, user-repo-root, inputs, inputs', pkgs, system, l, ... }:

ghc:

let

  formatters = iogx-interface."formatters.nix".load {
    inherit iogxRepoRoot repoRoot inputs inputs' pkgs system;
    lib = l;
  };


  haskell-toolchain = src.modules.haskell.internal.makeToolchainForGhc ghc;


  getExtraOptions = fmt: l.getAttrWithDefault "extraOptions" "" formatters.${fmt}; # FIXME


  pre-commit-hooks = {
    cabal-fmt = {
      enable = formatters.cabal-fmt.enable;
      extraOptions = getExtraOptions "cabal-fmt";
      package = haskell-toolchain.cabal-fmt;
      options = "--inplace";
      include = [ "cabal" ];
    };

    stylish-haskell = {
      enable = formatters.stylish-haskell.enable;
      extraOptions = getExtraOptions "stylish-haskell";
      package = haskell-toolchain.stylish-haskell;
      options = "--inplace --config .stylish-haskell.yaml";
      include = [ "hs" "lhs" ];
    };

    fourmolu = {
      enable = formatters.fourmolu.enable;
      extraOptions = getExtraOptions "fourmolu";
      package = haskell-toolchain.fourmolu;
      options = "--mode inplace";
      include = [ "hs" "lhs" ];
    };

    hlint = {
      enable = formatters.hlint.enable;
      extraOptions = getExtraOptions "hlint";
      package = haskell-toolchain.hlint;
      options = "--hint=.hlint.yaml";
      include = [ "hs" "lhs" ];
    };

    shellcheck = {
      enable = formatters.shellcheck.enable;
      extraOptions = getExtraOptions "shellcheck";
      package = pkgs.shellcheck;
      include = [ "sh" ];
    };

    prettier = {
      enable = formatters.prettier.enable;
      extraOptions = getExtraOptions "prettier";
      package = pkgs.nodePackages.prettier;
      include = [ "js" "css" "html" ];
      # types_or = [ "javascript" "css" "html" ]; TODO 
    };

    editorconfig-checker = {
      enable = formatters.editorconfig-checker.enable;
      extraOptions = getExtraOptions "editorconfig-checker";
      package = pkgs.editorconfig-checker;
      options = "-config .editorconfig";
      types = [ "file" ];
    };

    nixpkgs-fmt = {
      enable = formatters.nixpkgs-fmt.enable;
      extraOptions = getExtraOptions "nixpkgs-fmt";
      package = src.modules.formatters.ext.nixpkgs-fmt;
      include = [ "nix" ];
    };

    png-optimization = {
      enable = formatters.png-optimization.enable;
      extraOptions = getExtraOptions "png-optimization";
      package = pkgs.optipng;
      include = [ "png" ];
    };

    purs-tidy = {
      enable = formatters.purs-tidy.enable;
      options = "format-in-place";
      extraOptions = getExtraOptions "purs-tidy";
      package = (pkgs.callPackage iogx-inputs.easy-purescript-nix { }).purs;
      include = [ "purs" ];
      # language = "system"; # TODO
    };
  };


  makePreCommitHook = name: hook: l.mkForce {
    entry =
      "${l.getExe hook.package} " +
      "${l.getAttrWithDefault "options" "" hook} " +
      "${l.getAttrWithDefault "extraOptions" "" hook}";

    files =
      if hook ? include
      then "\\.(${l.concatStringsSep "|" hook.include})$"
      else "";

    enable = hook.enable;
    name = name;
    pass_filenames = true;
    types = l.getAttrWithDefault "types" [ ] hook;
  };


  package = iogx-inputs.pre-commit-hooks-nix.lib.${pkgs.stdenv.system}.run {
    src = l.cleanSource user-repo-root;
    hooks = l.mapAttrs makePreCommitHook pre-commit-hooks;
  };


  shell-profile = {
    packages = [ pkgs.pre-commit ];
    enterShell = package.shellHook;
  };


  pre-commit-check = { inherit package shell-profile; };

in

pre-commit-check
