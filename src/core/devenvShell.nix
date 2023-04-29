{ inputs, systemized-inputs, flakeopts, pkgs, l, iogx, ... }:

{ ghc, shell, flake }:

let

  filterDisabledScripts =
    l.filterAttrs (_: { enabled ? true, ... }: enabled);

  extractScriptDescriptions =
    l.mapAttrsToList (_: script: l.getAttrWithDefault "description" script "");

  makeUtilityDevenvModule = { user-module, standard-module }:
    let
      all-packages =
        l.getAttrWithDefault "packages" user-module [ ] ++
        l.getAttrWithDefault "packages" standard-module [ ];

      all-scripts =
        filterDisabledScripts (
          l.getAttrWithDefault "scripts" user-module { } //
          l.getAttrWithDefault "scripts" standard-module { }
        );

      list-haskell-outputs = {
        description = "list the haskell outputs buildable by nix";
        exec =
          let
            printGroup = group: command:
              if group == "devShells" then
                l.concatStringsSep "\n"
                  (
                    map (ghc: "nix develop .#${ghc}\nnix develop .#${ghc}-profiled")
                      flakeopts.haskell.compilers)
              else
                l.concatStringsSep "\n" (
                  l.mapAttrsToList (name: _: "nix ${command} .#${name}")
                    flake.${group});

            content = ''
            
              ******************** Haskell Packages ******************** 

              ${printGroup "packages" "build"}

              ******************** Haskell Apps ******************** 

              ${printGroup "apps" "run"}

              ******************** Development Shells ******************** 

              ${printGroup "devShells" "develop"}
            '';
          in
          ''
            echo "${content}"
          '';
      };

      menu = {
        description = "print this message";
        exec =
          let
            extra-names = [
              "list-haskell-outputs"
              "menu"
            ];
            extra-descriptions = [
              list-haskell-outputs.description
              "print this message"
            ];
            content = l.prettyTwoColumnsLayout {
              indent = "👉 ";
              lefts = extra-names ++ l.attrNames all-scripts;
              rights = extra-descriptions ++ extractScriptDescriptions all-scripts;
              gap-width = 4;
            };
          in
          ''
            echo
            echo
            echo -e "🤟 \033[1;31m${flakeopts.shellName}\033[0m development shell"
            echo 
            echo "${content}"
            echo
            echo
          '';
      };

      utility-module = {
        scripts = { inherit list-haskell-outputs menu; };
        enterShell = ''
          export PS1="${flakeopts.shellPrompt}"
          menu
        '';
      };
    in
    utility-module;

  fixupDevenvModule = module:
    let
      scripts = l.getAttrWithDefault "scripts" module { };
      filtered-scripts = filterDisabledScripts scripts;
      # Very fiddly! This does the trick, makes devevn.sh happy.
      mkScript = name: script: { scripts.${name}.exec = script.exec; };
      final-scripts = l.recursiveUpdateMany (l.mapAttrsToList mkScript filtered-scripts);
      final-module = module // final-scripts;
    in
    final-module;

  devenvShell =
    let
      # NOTE: calling config function
      user-module = flakeopts.defaultShell
        { inherit inputs systemized-inputs flakeopts pkgs; };

      standard-module = iogx.core.devenvModule
        { inherit ghc shell; };

      utility-module = makeUtilityDevenvModule
        { inherit user-module standard-module; };

      modules = map fixupDevenvModule [
        standard-module
        user-module
        utility-module
      ];
    in
    inputs.devenv.lib.mkShell {
      inherit pkgs inputs modules;
    };
in
devenvShell

