{ src, iogx-inputs, nix, iogx-interface, inputs, inputs', pkgs, l, system, ... }:

projects: # The haskell.nix projects with the meta field, prefixed by ghc config

let
  haskell = iogx-interface."haskell.nix".load
    { inherit nix inputs inputs' pkgs l system; };


  haskellLib = pkgs.haskell-nix.haskellLib;


  # :: haskell.nix-project(with meta field) -> flake-outputs
  # If we only have one compiler, then the compiler name will not be appended 
  # to the component names.
  # If we have more than one supported compilers, then the compiler name will
  # be appended to all components.
  # In addition, aliases for the *executables* only will be added to the outputs.
  # Only the cabal 'exes' will be aliased, both in 'packages' and in 'apps'.
  # If we only have one compiler, then the compiler named will not the appended
  # to the alias names.
  # If we have more than one supported compilers, then the compiler name will
  # also not be appended to the executables, and only aliases for the default
  # compiler will be created.
  makeFlakeOutputsForProject = project:
    let
      flake = haskellLib.mkFlake project { };

      meta = project.meta;

      is-single-ghc = l.length haskell.supportedCompilers < 2;

      renameGroup = group:
        let mkPair = name: l.nameValuePair (renameComponent name);
        in l.mapAttrs' mkPair group;

      # $type = exe|lib|test|bench|sublib
      # $pkg:$type:$comp -> $pkg-$type-$comp(-profiled?)(-mingwW64?)(-$ghc?)
      renameComponent = name:
        let
          replaceCons = l.replaceStrings [ ":" ] [ "-" ];
          ghc = if is-single-ghc then "" else "-${meta.haskellCompiler}";
          name' = replaceCons name;
          cross = if meta.enableCross then "-mingwW64" else "";
          profiled' = l.optionalString meta.enableProfiling "-profiled";
        in
        "${name'}${profiled'}${cross}${ghc}";

      makeAliasesForGroupExes = group:
        let
          is-default-compiler = meta.haskellCompiler == haskell.defaultCompiler;
          mkPair = name: l.nameValuePair (makeAliasForExe name);
          exes = l.filterAttrs (name: _: l.strings.hasInfix ":exe:" name) group;
          group' = l.mapAttrs' mkPair exes;
        in
        l.optionalAttrs is-default-compiler group';

      # $type = exe|lib|test|bench|sublib
      # $pkg:$type:$comp -> $comp(-profiled?)(-mingwW64?)(-$ghc?)
      makeAliasForExe = name:
        let
          ghc = "";
          name' = l.last (l.splitString ":" name);
          cross = if meta.enableCross then "-mingwW64" else "";
          profiled' = l.optionalString meta.enableProfiling "-profiled";
        in
        "${name'}${profiled'}${cross}${ghc}";

      findDuplicateExes = group:
        let names = l.attrNames (makeAliasesForGroupExes group);
        in l.findDuplicates names;

      makeAliasesForGroupExesIfNoDuplicates = group:
        let duplicates = findDuplicateExes group;
        in
        if l.length duplicates == 0 then
          makeAliasesForGroupExes group
        else
          warnDuplicateComponentNames duplicates { };

      warnDuplicateComponentNames = duplicates: l.iogxTrace ''
        There are multiple executables with the same name across your cabal files:

          ${l.concatStringsSep " " duplicates}

        Therefore I cannot create flake output aliases for your executables.
        Rename the executables across your cabal files so that they are unique.
        This doesn't affect testsuites, libraries nor benchmarks.'';

      extra-packages = {
        haskell-nix-project-roots = flake.hydraJobs.roots;
        haskell-nix-project-plan-nix = flake.hydraJobs.plan-nix;
      };

      outputs = {
        apps =
          renameGroup flake.apps //
          makeAliasesForGroupExesIfNoDuplicates flake.apps;

        checks = renameGroup flake.checks;

        packages =
          renameGroup extra-packages //
          renameGroup flake.packages //
          makeAliasesForGroupExesIfNoDuplicates flake.packages;
      };
    in
    outputs;


  outputs =
    let projects-list = l.attrValues projects;
    in l.recursiveUpdateMany (map makeFlakeOutputsForProject projects-list);

in

outputs
