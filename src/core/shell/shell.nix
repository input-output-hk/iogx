{ inputs, inputs', pkgs, l, src, iogx-interface, ... }:

{ project }:

let

  mergeModules = mod1: mod2: mod1 // mod2 // 
    {
      packages = # TODO check collisions
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

      env = # TODO check collisions
        l.getAttrWithDefault "env" { } mod1 //
        l.getAttrWithDefault "env" { } mod2;
    };


  mergeManyModules = l.foldl' mergeModules { };


  scriptToShellApp = name: script: pkgs.writeShellScriptBin name "${script.exec}";


  scriptsToShellApps = scripts:
    let
      filterDisabled = l.filterAttrs (_: { enable ? true, ... }: enable);
    in
    l.mapAttrsToList scriptToShellApp (filterDisabled scripts);


  envToShellHook = env:
    let
      exportVar = key: val: ''export ${key}="${val}"'';
    in
    l.concatStringsSep "\n" (l.mapAttrsToList exportVar env);


  pre-commit-check = src.core.pre-commit-check { inherit project; };


  shellToNixShell = shell: 
    pkgs.mkShell {
      name = shell.name;
      buildInputs = shell.packages ++ scriptsToShellApps shell.scripts;
      shellHook = ''
        ${shell.enterShell}
        ${envToShellHook shell.env}
        ${pre-commit-check.shellHook}
        export PS1="${shell.prompt}"
        info 
      '';
    };


  shell =
    let
      base-module = src.core.shell.base-module { inherit project; };

      user-shell = iogx-interface.load-shell { inherit inputs inputs' pkgs project; };

      readthedocs-module = {}; # TODO

      utility-module = src.core.shell.utility-module { shell = __shell__; };

      __shell__ = mergeManyModules [
        base-module
        readthedocs-module
        utility-module
        user-shell # TODO comment shell/module difference
      ];
    in
    shellToNixShell __shell__;

in

shell

