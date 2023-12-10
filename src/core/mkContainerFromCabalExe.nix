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

  name =
    if lib.isNull userConfig.name then
      userConfig.exe.exeName
    else
      userConfig.name;

  license =
    let
      ls = userConfig.exe.meta.license;
    in
    if (lib.isAttrs ls) then
      ls.spdxId
    else if (lib.isList ls && [ ] != ls) then
      let
        l = (lib.head ls);
      in
      if lib.isAttrs l then
        l.spdxId
      else
        null
    else null;

  labels = lib.pipe
    {
      inherit license;
      inherit (userConfig) description;
    }
    [
      (lib.filterAttrs (k: v: v != null))
      (lib.mapAttrs' (k: v: lib.nameValuePair "org.opencontainers.image.${k}" v))
    ];

  rootEnv =
    if (!lib.isNull userConfig.packages && userConfig.packages != [ ]) then
      pkgs.buildEnv
        {
          name = "root";
          paths = userConfig.packages;
          pathsToLink = [ "/bin" ];
        }
    else
      null;
in
nix2container.buildImage ({
  inherit name;

  config = {
    entryPoint = lib.singleton (lib.getExe userConfig.exe);
  } // lib.optionalAttrs (labels != { }) {
    Labels = labels;
  };
} // lib.optionalAttrs (rootEnv != null) {
  copyToRoot = [ rootEnv ];
})
