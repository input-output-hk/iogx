{ src, iogx-inputs, iogx-interface, inputs, inputs', pkgs, l, ... }:

let

  assembleNonHaskellFlake =
    let
      pre-commit-check = src.modules.formatters.makePreCommitCheck "ghc8107";

      read-the-docs-packages =
        let site = src.modules.read-the-docs.makeReadTheDocsSite;
        in l.optionalAttrs (site != null) { read-the-docs-site = site; };

      devShell = src.modules.shell.makeDevShellWith {
        extra-profiles = [
          src.modules.read-the-docs.makeShellProfile
          pre-commit-check.shell-profile
        ];
      };

      flake = l.recursiveUpdateMany [
        {
          packages.pre-commit-check = pre-commit-check.package;
        }
        {
          packages = read-the-docs-packages;
        }
        {
          devShells.default = devShell;
        }
        {
          hydraJobs = src.modules.ci.makeHydraJobs;
        }
        (
          src.modules.per-system-outputs.makePerSystemOutputsWith { }
        )
      ];
    in
    flake;


  assembleHaskellFlake =
    let
      projects = src.modules.haskell.makeCabalProjects;

      pre-commit-checks =
        let
          mkOne = ghc: project:
            let
              ghc = project.meta.haskellCompiler;
              value = src.modules.formatters.makePreCommitCheck ghc;
            in
            l.nameValuePair ghc value;
        in
        l.mapAttrs' mkOne projects.unprofiled;

      devShells =
        let
          mkOne = project: src.modules.shell.makeDevShellWith {
            extra-args = { inherit project; };
            extra-profiles = [
              src.modules.read-the-docs.makeShellProfile
              pre-commit-checks.${project.meta.haskellCompiler}.shell-profile
              (src.modules.haskell.makeShellProfileForProject project)
            ];
          };
          all = l.mapAttrValues mkOne projects.all;
          default = all.${projects.default-prefix};
          profiled = all.${projects.profiled-prefix};
        in
        if projects.count == 1 then
          { inherit default profiled; }
        else
          all // { inherit default profiled; };

      pre-commit-check-packages =
        l.mapAttrs'
          (ghc: pre-commit-check:
            l.nameValuePair "pre-commit-check-${ghc}" pre-commit-check.package
          )
          pre-commit-checks;

      read-the-docs-packages =
        let site = src.modules.read-the-docs.makeReadTheDocsSite;
        in l.optionalAttrs (site != null) { read-the-docs-site = site; };

      per-system-outputs =
        src.modules.per-system-outputs.makePerSystemOutputsWith {
          extra-args = { inherit projects; };
        };

      haskell-flake-outputs =
        src.modules.haskell.makeAggregatedFlakeOutputsForProjects projects.all;

      cross-compiled-projects =
        src.modules.haskell.makeCrossCompiledAttrsetForProjects projects.all;

      flake = l.recursiveUpdateMany [
        {
          packages = pre-commit-check-packages;
        }
        {
          packages = read-the-docs-packages;
        }
        {
          inherit devShells;
        }
        {
          hydraJobs = src.modules.ci.makeHydraJobs;
        }
        {
          hydraJobs = cross-compiled-projects;
        }
        (
          per-system-outputs
        )
        (
          haskell-flake-outputs
        )
      ];
    in
    flake;

in

if iogx-interface."haskell.nix".exists then
  assembleHaskellFlake
else
  assembleNonHaskellFlake 
  


