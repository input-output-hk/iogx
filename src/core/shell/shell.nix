{ inputs, inputs', pkgs, l, src, iogx-interface, ... }:

{ project, __flake__ }:

let

  mergeModules = mod1: mod2: mod1 // mod2 // 
    {
      packages = 
        l.getAttrWithDefault "packages" [ ] mod1 ++
        l.getAttrWithDefault "packages" [ ] mod2;

      enterShell =
        l.concatStringsSep "\n" [
          (l.getAttrWithDefault "enterShell" "" mod1)
          (l.getAttrWithDefault "enterShell" "" mod2)
        ];

      scripts = 
        let 
          scripts1 = l.getAttrWithDefault "scripts" { } mod1;
          scripts2 = l.getAttrWithDefault "scripts" { } mod2;
          mkErrmsg = { n, duplicates }: l.iogxError "shell" ''
            Your nix/shell.nix contains ${toString n} invalid ${l.plural n "script"}:

              ${l.concatStringsSep ", " duplicates}
            
            IOGX already defines scripts with the same name.
          '';
        in 
          l.mergeDisjointAttrsOrThrow scripts1 scripts2 mkErrmsg;

      env = 
        let 
          env1 = l.getAttrWithDefault "env" { } mod1;
          env2 = l.getAttrWithDefault "env" { } mod2;
          mkErrmsg = { n, duplicates }: l.iogxError "shell" ''
            Your nix/shell.nix contains ${toString n} invalid environment ${l.plural n "variable"}:

              ${l.concatStringsSep ", " duplicates}
            
            IOGX already defines environment variables with the same name.
          '';
        in 
          l.mergeDisjointAttrsOrThrow env1 env2 mkErrmsg;
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


  pre-commit-check = __flake__.packages."pre-commit-check-${project.meta.haskellCompiler}";


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

      readthedocs-module = {};

      utility-module = src.core.shell.utility-module { inherit __shell__ __flake__; };

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

