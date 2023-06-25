{ inputs, inputs', iogx-config, iogx-interface, pkgs, l, src, ... }:

{ haskellCompiler }:

let 

  haskell-toolchain = src.toolchain."haskell-toolchain-${haskellCompiler}";


  user-hooks = iogx-interface.load-pre-commit-check null;


  default-hooks = {

    cabal-fmt = {
      enable = false;
      command = l.getExe src.toolchain.cabal-fmt;
      options = "--inplace";
      include = ["cabal"];
      passFilenames = true;
    };

    stylish-haskell = rec {
      enable = false;
      command = l.getExe haskell-toolchain.stylish-haskell;
      options = "--inplace --config .stylish-haskell.yaml";
      include = ["hs" "lhs"];
    };

    shellcheck = {
      enable = false;
      command = l.getExe pkgs.shellcheck;
      include = ["sh"];
    };

    prettier = {
      enable = false;
      command = l.getExe pkgs.nodePackages.prettier;
      include = ["js" "css" "html"];
    };

    editorconfig-checker = {
      enable = false; 
      command = l.getExe pkgs.editorconfig-checker;
      options = "-config .editorconfig";
      types = ["file"];
    };

    nixpkgs-fmt = {
      enable = false;
      command = l.getExe src.toolchain.nixpkgs-fmt;
      include = ["nix"];
    };

    png-optimization = {
      enable = false;
      command = l.getExe pkgs.optipng;
      include = ["png"];
    };

    fourmolu = {
      enable = false;
      command = l.getExe haskell-toolchain.fourmolu;
      options = "--mode inplace";
      include = ["hs" "lhs"];
    };

    hlint = {
      enable = false;
      command = l.getExe haskell-toolchain.hlint;
      options = "--hint=.hlint.yaml";
      include = ["hs" "lhs"];
    };

    # FIXME Breaks with -XExplicitNamespaces type (:<|>)
    hindent = {
      enable = false;
      command = l.getExe haskell-toolchain.hindent;
      include = ["hs" "lhs"];
    };
  };


  mkPccnHook = name: hook: l.mkForce {
    entry = 
      "${hook.command} " + 
      "${l.getAttrWithDefault "options" "" hook} " + 
      "${l.getAttrWithDefault "extraOptions" "" hook}";

    files = 
      if hook ? include 
      then "\\.(${l.concatStringsSep "|" hook.include})$"
      else "";

    enable = hook.enable;
    name = name;
    pass_filenames = true;
    types = l.getAttrWithDefault "types" [] hook;
  };


  merged-hooks = l.mapAttrs mkPccnHook (l.recursiveUpdate default-hooks user-hooks);


  pre-commit-check = inputs.pre-commit-hooks-nix.lib.${pkgs.stdenv.system}.run {
    src = pkgs.lib.cleanSource iogx-config.repoRoot;
    hooks = merged-hooks;
  };

in 

  pre-commit-check