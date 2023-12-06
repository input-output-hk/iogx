{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

userConfig':

let
  inherit (iogx-inputs.nix2container.packages) nix2container;

  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config."mkContainerFromCabalExe.<in>" = userConfig';
    }];
  };

  userConfig = evaluated-modules.config."mkContainerFromCabalExe.<in>";
in
nix2container.buildImage {
  name = userConfig.exe.exeName;

  config.entryPoint = lib.singleton (lib.getExe userConfig.exe);
}
