{ inputs, systemized-inputs, flakeopts, pkgs, l, iogx, ... }:

{ shell, flake }:

let
  # # Very fiddly! This does the trick, makes devevn.sh happy.
  # adaptDevenvModule = module:
  #   let
  #     scripts = l.getAttrWithDefault "scripts" { } module;
  #     filtered-scripts = filterDisabledScripts scripts;
  #     mkScript = name: script: { scripts.${name}.exec = script.exec; };
  #     final-scripts = l.recursiveUpdateMany (l.mapAttrsToList mkScript filtered-scripts);
  #   in
  #   module // final-scripts;

  mergeModules = mod1: mod2:
    {
      packages =
        l.getAttrWithDefault "packages" [ ] mod1 ++
        l.getAttrWithDefault "packages" [ ] mod2;

      enterShell =
        l.concatStringsSep "\n" [
          (l.getAttrWithDefault "enterShell" "" mod1)
          (l.getAttrWithDefault "enterShell" "" mod2)
        ];

      scripts = # TODO check collisions
        l.getAttrWithDefault "scripts" { } mod1 //
        l.getAttrWithDefault "scripts" { } mod2;

      env =
        l.getAttrWithDefault "env" { } mod1 //
        l.getAttrWithDefault "env" { } mod2;
    };


  mergeManyModules = l.foldl' mergeModules { };


  scriptToShellApp = name: script: pkgs.writeShellScriptBin name "${script.exec}";


  scriptsToShellApps = scripts:
    let
      filterDisabled = l.filterAttrs (_: { enabled ? true, ... }: enabled);
    in
    l.mapAttrsToList scriptToShellApp (filterDisabled scripts);


  envToShellHook = env:
    let
      exportVar = key: val: ''export ${key}="${val}"'';
    in
    l.concatStringsSep "\n" (l.mapAttrsToList exportVar env);


  moduleToShell = mod:
    pkgs.mkShell {
      name = "${flakeopts.shellName}-shell";
      buildInputs = mod.packages ++ scriptsToShellApps mod.scripts;
      shellHook = mod.enterShell + "\n" + envToShellHook mod.env;
    };


  devShell =
    let
      base-module = iogx.core.mkDevShell.mkBaseModule
        { inherit shell; };

      # NOTE: calling config function
      user-module = flakeopts.shellModule
        { inherit inputs systemized-inputs flakeopts pkgs; };

      readthedocs-module =
        l.optionalAttrs flakeopts.includeReadTheDocsSite iogx.readthedocs.devenv-module;

      utility-module = iogx.core.mkDevShell.mkUtilityModule {
        inherit flake;
        core-modules = [ base-module user-module readthedocs-module ];
      };

      merged-module = mergeManyModules [
        base-module
        user-module
        readthedocs-module
        utility-module
      ];
    in
    moduleToShell merged-module;
  # inputs.devenv.lib.mkShell {
  #   inherit pkgs inputs modules;
  # };
in
devShell

