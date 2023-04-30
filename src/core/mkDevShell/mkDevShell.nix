{ inputs, systemized-inputs, flakeopts, pkgs, l, iogx, ... }:

{ shell, flake }:

let
  # Very fiddly! This does the trick, makes devevn.sh happy.
  adaptDevenvModule = module:
    let
      filterDisabledScripts = l.filterAttrs (_: { enabled ? true, ... }: enabled);
      scripts = l.getAttrWithDefault "scripts" { } module;
      filtered-scripts = filterDisabledScripts scripts;
      mkScript = name: script: { scripts.${name}.exec = script.exec; };
      final-scripts = l.recursiveUpdateMany (l.mapAttrsToList mkScript filtered-scripts);
    in
    module // final-scripts;


  devShell =
    let
      base-module = iogx.core.mkDevShell.mkBaseModule
        { inherit shell; };

      # NOTE: calling config function
      user-module = flakeopts.shellModule
        { inherit inputs systemized-inputs flakeopts pkgs; };

      readthedocs-module =
        l.optionalAttrs flakeopts.includeReadTheDocsSite iogx.readthedocs.devenv-module;

      core-modules = [ base-module user-module readthedocs-module ];

      utility-module = iogx.core.mkDevShell.mkUtilityModule
        { inherit flake core-modules; };

      modules = map adaptDevenvModule [
        base-module
        user-module
        readthedocs-module
        utility-module
      ];
    in
    inputs.devenv.lib.mkShell {
      inherit pkgs inputs modules;
    };
in
devShell

