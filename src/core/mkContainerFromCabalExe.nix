{ repoRoot, iogx-inputs, user-inputs, pkgs, lib, system, ... }:

mkContainerFromCabalExe-IN:

let
  inherit (iogx-inputs.nix2container.packages) nix2container;

  evaluated-modules = lib.evalModules {
    modules = [{
      options = lib.iogx.options;
      config."mkContainerFromCabalExe.<in>" = mkContainerFromCabalExe-IN;
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
      source = userConfig.sourceUrl;
    }
    [
      (lib.filterAttrs (k: v: v != null))
      (lib.mapAttrs' (k: v: lib.nameValuePair "org.opencontainers.image.${k}" v))
    ];

  rootPackages = [
    # Provide some tools for users who want to enter a shell in the running
    # container.
    (pkgs.buildEnv {
      name = "base";
      paths = [
        pkgs.bashInteractive
        pkgs.coreutils
      ];
      pathsToLink = [ "/bin" ];
    })

    # Some networked applications need cacerts on the machine
    pkgs.cacert

    # Fixes networking on some platforms
    pkgs.fakeNss
  ] ++ lib.optional (!lib.isNull userConfig.packages && userConfig.packages != [ ])
    (pkgs.buildEnv {
      name = "user";
      paths = userConfig.packages;
      pathsToLink = [ "/bin" ];
    });
in
nix2container.buildImage ({
  inherit name;

  config = {
    entryPoint = lib.singleton (lib.getExe userConfig.exe);
  } // lib.optionalAttrs (labels != { }) {
    Labels = labels;
  };

  copyToRoot = rootPackages;
})
