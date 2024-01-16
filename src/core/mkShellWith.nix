{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

# Create an actual nix devShell with a bunch of tools and utilities.

# The shell config provided by the user.
mkShell-IN:

# Extra profiles. Internally these will be read-the-docs and haskell-nix.
extra-shell-profiles:

let

  utils = lib.iogx.utils;


  evaluated-shell-module = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config."mkShell.<in>" = mkShell-IN;
    }];
  };


  shell' = evaluated-shell-module.config."mkShell.<in>";


  shell = lib.recursiveUpdate shell' {

    prompt =
      if shell'.prompt == null
      then "\n\\[\\033[1;32m\\][${shell'.name}:\\w]\\$\\[\\033[0m\\] "
      else shell'.prompt;

    welcomeMessage =
      if shell'.welcomeMessage == null
      then "🤟 \\033[1;31mWelcome to ${shell'.name}\\033[0m 🤟"
      else shell'.welcomeMessage;
  };


  ghc =
    if shell.tools.haskellCompilerVersion == null
    then "ghc8107"
    else shell.tools.haskellCompilerVersion;


  hls = repoRoot.src.ext.haskell-language-server-project ghc;
  hls96 = repoRoot.src.ext.haskell-language-server-project "ghc96";


  purescript = pkgs.callPackage iogx-inputs.easy-purescript-nix { };


  getHlsTool = name:
    let hls' = if lib.hasInfix ghc "ghc98" then hls96 else hls;
    in hls'.hsPkgs.${name}.components.exes.${name};


  default-tools = {
    cabal-install = repoRoot.src.ext.cabal-install ghc;
    haskell-language-server = hls.hsPkgs.haskell-language-server.components.exes.haskell-language-server;
    haskell-language-server-wrapper = hls.hsPkgs.haskell-language-server.components.exes.haskell-language-server-wrapper;

    stylish-haskell = getHlsTool "stylish-haskell";
    hlint = getHlsTool "hlint";
    cabal-fmt = repoRoot.src.ext.cabal-fmt;
    fourmolu = repoRoot.src.ext.fourmolu;

    shellcheck = pkgs.shellcheck;
    prettier = pkgs.nodePackages.prettier;
    editorconfig-checker = pkgs.editorconfig-checker;
    nixpkgs-fmt = repoRoot.src.ext.nixpkgs-fmt;
    optipng = pkgs.optipng;
    purs-tidy = purescript.purs-tidy;
  };


  getTool = name:
    if utils.getAttrWithDefault name null shell.tools == null
    then default-tools.${name}
    else shell.tools.${name};


  shell-tools = {
    cabal-install = getTool "cabal-install";
    cabal-fmt = getTool "cabal-fmt";
    stylish-haskell = getTool "stylish-haskell";
    fourmolu = getTool "fourmolu";
    hlint = getTool "hlint";
    shellcheck = getTool "shellcheck";
    prettier = getTool "prettier";
    editorconfig-checker = getTool "editorconfig-checker";
    nixpkgs-fmt = getTool "nixpkgs-fmt";
    optipng = getTool "optipng";
    purs-tidy = getTool "purs-tidy";
    haskell-language-server = getTool "haskell-language-server";
    haskell-language-server-wrapper = getTool "haskell-language-server-wrapper";
  };


  getPreCommitIncludeList = name: default:
    if shell.preCommit.${name}.include == null
    then default
    else shell.preCommit.${name}.include;


  pre-commit-hooks = {
    cabal-fmt = {
      enable = shell.preCommit.cabal-fmt.enable;
      extraOptions = shell.preCommit.cabal-fmt.extraOptions;
      package = shell-tools.cabal-fmt;
      excludes = shell.preCommit.cabal-fmt.excludes;
      options = "--inplace";
      include = getPreCommitIncludeList "cabal-fmt" [ "cabal" ];
    };

    stylish-haskell = {
      enable = shell.preCommit.stylish-haskell.enable;
      extraOptions = shell.preCommit.stylish-haskell.extraOptions;
      package = shell-tools.stylish-haskell;
      excludes = shell.preCommit.stylish-haskell.excludes;
      options = "--inplace --config .stylish-haskell.yaml";
      include = getPreCommitIncludeList "stylish-haskell" [ "hs" "lhs" ];
    };

    fourmolu = {
      enable = shell.preCommit.fourmolu.enable;
      extraOptions = shell.preCommit.fourmolu.extraOptions;
      package = shell-tools.fourmolu;
      excludes = shell.preCommit.fourmolu.excludes;
      options = "--mode inplace";
      include = getPreCommitIncludeList "fourmolu" [ "hs" "lhs" ];
    };

    hlint = {
      enable = shell.preCommit.hlint.enable;
      extraOptions = shell.preCommit.hlint.extraOptions;
      package = shell-tools.hlint;
      excludes = shell.preCommit.hlint.excludes;
      options = "--hint=.hlint.yaml";
      include = getPreCommitIncludeList "hlint" [ "hs" "lhs" ];
    };

    shellcheck = {
      enable = shell.preCommit.shellcheck.enable;
      extraOptions = shell.preCommit.shellcheck.extraOptions;
      package = shell-tools.shellcheck;
      include = getPreCommitIncludeList "shellcheck" [ "sh" ];
      excludes = shell.preCommit.shellcheck.excludes;
    };

    prettier = {
      enable = shell.preCommit.prettier.enable;
      extraOptions = shell.preCommit.prettier.extraOptions;
      package = shell-tools.prettier;
      include = getPreCommitIncludeList "prettier" [ "js" "css" "html" ];
      excludes = shell.preCommit.prettier.excludes;
    };

    editorconfig-checker = {
      enable = shell.preCommit.editorconfig-checker.enable;
      extraOptions = shell.preCommit.editorconfig-checker.extraOptions;
      package = shell-tools.editorconfig-checker;
      excludes = shell.preCommit.editorconfig-checker.excludes;
      options = "-config .editorconfig";
      types = [ "file" ];
    };

    nixpkgs-fmt = {
      enable = shell.preCommit.nixpkgs-fmt.enable;
      extraOptions = shell.preCommit.nixpkgs-fmt.extraOptions;
      package = shell-tools.nixpkgs-fmt;
      include = getPreCommitIncludeList "nixpkgs-fmt" [ "nix" ];
      excludes = shell.preCommit.nixpkgs-fmt.excludes;
    };

    optipng = {
      enable = shell.preCommit.optipng.enable;
      extraOptions = shell.preCommit.optipng.extraOptions;
      package = shell-tools.optipng;
      include = getPreCommitIncludeList "optipng" [ "png" ];
      excludes = shell.preCommit.optipng.excludes;
    };

    purs-tidy = {
      enable = shell.preCommit.purs-tidy.enable;
      extraOptions = shell.preCommit.purs-tidy.extraOptions;
      options = "format-in-place";
      package = shell-tools.purs-tidy;
      include = getPreCommitIncludeList "purs-tidy" [ "purs" ];
      excludes = shell.preCommit.purs-tidy.excludes;
    };
  };


  mkPreCommitHook = name: hook: lib.mkForce {
    entry =
      "${lib.getExe' hook.package name} " +
      "${utils.getAttrWithDefault "options" "" hook} " +
      "${utils.getAttrWithDefault "extraOptions" "" hook}";

    files =
      if hook ? include
      then "\\.(${lib.concatStringsSep "|" hook.include})$"
      else "";

    enable = hook.enable;
    excludes = hook.excludes;
    name = name;
    pass_filenames = true;
    types = utils.getAttrWithDefault "types" [ ] hook;
  };


  toolchain-profile =
    let
      should-include-haskell-tools =
        shell.tools.haskellCompilerVersion != null ||
        pre-commit-hooks.cabal-fmt.enable ||
        pre-commit-hooks.stylish-haskell.enable ||
        pre-commit-hooks.fourmolu.enable ||
        pre-commit-hooks.hlint.enable;

      haskell-tools = [
        shell-tools.haskell-language-server
        shell-tools.haskell-language-server-wrapper
        shell-tools.cabal-install
        shell-tools.cabal-fmt
        shell-tools.stylish-haskell
        shell-tools.fourmolu
        shell-tools.hlint
      ];

      pre-commit-packages =
        let getPkg = _: hook: if hook.enable then hook.package else null;
        in lib.mapAttrsToList getPkg pre-commit-hooks;

      packages =
        pre-commit-packages ++
        lib.optional should-include-haskell-tools haskell-tools;
    in
    { inherit packages; };


  pre-commit-check = iogx-inputs.pre-commit-hooks-nix.lib.${system}.run {
    src = lib.cleanSource user-inputs.self;
    hooks = lib.mapAttrs mkPreCommitHook pre-commit-hooks;
  };


  pre-commit-profile-packages = lib.mapAttrsToList
    (name: hook: if hook.enable then hook.package else null)
    pre-commit-hooks;


  pre-commit-profile = {
    packages = [ pkgs.pre-commit ];
    shellHook = pre-commit-check.shellHook;
  };


  shell-as-shell-profile =
    removeAttrs shell [ "name" "prompt" "welcomeMessage" ];


  name-and-welcome-message-profile = {
    shellHook = ''  
      export PS1="${shell.prompt}"
      echo 
      printf "${shell.welcomeMessage}"
      echo
      echo
      echo "Type 'info' to see what's inside this shell."
    '';
  };


  local-archive-profile.env.LOCALE_ARCHIVE = lib.optionalString
    (pkgs.stdenv.hostPlatform.libc == "glibc")
    ("${pkgs.glibcLocales}/lib/locale/locale-archive");


  base-profile = repoRoot.src.core.mkMergedShellProfiles (
    extra-shell-profiles ++
    [
      pre-commit-profile
      shell-as-shell-profile
      local-archive-profile
      toolchain-profile
      name-and-welcome-message-profile
    ]
  );


  utility-scripts-profile = {
    scripts = repoRoot.src.core.mkShellUtilityScripts base-profile;
  };


  final-profile = repoRoot.src.core.mkMergedShellProfiles [
    base-profile
    utility-scripts-profile
  ];


  final-scripts-as-packages =
    let
      removeDisabled = lib.filterAttrs (_: { enable ? true, ... }: enable);
      enabled-scripts = removeDisabled final-profile.scripts;
      scriptToPackage = name: script: pkgs.writeShellScriptBin name "${script.exec}";
    in
    lib.mapAttrsToList scriptToPackage enabled-scripts;


  final-env-as-bash =
    let exportVar = key: val: ''export ${key}="${toString val}"'';
    in lib.concatStringsSep "\n" (lib.mapAttrsToList exportVar final-profile.env);


  devShell' = pkgs.mkShell {
    name = shell.name;
    buildInputs = final-profile.packages ++ final-scripts-as-packages;
    shellHook = ''  
      ${final-profile.shellHook}
      ${final-env-as-bash}
    '';
  };


  devShell = devShell' // {
    tools = shell-tools;
    inherit pre-commit-check;
  };

in

devShell
