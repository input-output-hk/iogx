{ src, iogx-inputs, user-repo-root, inputs, inputs', pkgs, l, ... }:

project: # The haskell.nix projects with the meta field, prefixed by ghc config

let
  haskellLib = pkgs.haskell-nix.haskellLib;


  # :: haskell.nix-project(with meta field) -> shell-profile
  shell-profile =
    let
      base-profile =
        let
          devshell = haskellLib.devshellFor project.shell;
          packages = devshell.packages;
          env = l.listToAttrs devshell.env;
        in
        { inherit packages env; };

      toolchain-profile =
        let ghc = project.meta.haskellCompiler;
        in src.modules.haskell.internal.makeToolchainShellProfileForGhc ghc;

      changelog-profile =
        src.modules.haskell.internal.makeChangelogShellProfile;

      merged-profile = src.modules.shell.makeMergedShellProfile [
        base-profile
        toolchain-profile
        changelog-profile
      ];
    in
    merged-profile;

in

shell-profile
  

