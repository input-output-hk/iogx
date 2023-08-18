{ src, iogx-inputs, repoRoot, iogxRepoRoot, iogx-interface, inputs, inputs', pkgs, l, system, ... }:

{ extra-profiles ? [ ] # extra profiles to merge into the final shell
, extra-args ? { } # extra arguments to pass to ./nix/shell.nix
}:

let

  # This is how we'll pass project to ./nix/shell.nix when ./nix/haskell.nix exists
  user-shell = iogx-interface."shell.nix".load ({
    inherit iogxRepoRoot repoRoot inputs inputs' pkgs system;
    lib = l;
  } // extra-args);


  user-shell-as-shell-profile =
    removeAttrs user-shell [ "name" "prompt" "welcomeMessage" ];


  name-and-welcome-message-profile = {
    enterShell = ''  
      export PS1="${user-shell.prompt}"
      echo 
      printf "${user-shell.welcomeMessage}"
      echo
      echo
      echo "Type 'info' to see what's inside this shell."
    '';
  };


  local-archive-shell-profile = {
    env.LOCALE_ARCHIVE =
      l.optionalString
        (pkgs.stdenv.hostPlatform.libc == "glibc")
        ("${pkgs.glibcLocales}/lib/locale/locale-archive");
  };


  base-profile = src.modules.shell.makeMergedShellProfile (
    extra-profiles ++
    [
      name-and-welcome-message-profile
      user-shell-as-shell-profile
      local-archive-shell-profile
    ]
  );


  utility-scripts-profile =
    src.modules.shell.internal.makeUtilityScriptsShellProfile base-profile;


  final-profile = src.modules.shell.makeMergedShellProfile (
    [
      base-profile
      utility-scripts-profile
    ]
  );


  devShell =
    let
      scripts-as-packages =
        let
          removeDisabled = l.filterAttrs (_: { enable ? true, ... }: enable);
          enabled-scripts = removeDisabled final-profile.scripts;
          scriptToPackage = name: script: pkgs.writeShellScriptBin name "${script.exec}";
        in
        l.mapAttrsToList scriptToPackage enabled-scripts;

      env-as-bash =
        let exportVar = key: val: ''export ${key}="${toString val}"'';
        in l.concatStringsSep "\n" (l.mapAttrsToList exportVar final-profile.env);
    in
    pkgs.mkShell {
      name = user-shell.name;
      buildInputs = final-profile.packages ++ scripts-as-packages;
      shellHook = ''  
        ${final-profile.enterShell}
        ${env-as-bash}
      '';
    };

in

devShell
