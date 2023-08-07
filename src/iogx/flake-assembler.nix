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

      pre-commit-checks = l.mapAttrs'
        (ghc: project:
          let
            ghc = project.meta.haskellCompiler;
            name = ghc;
            value = src.modules.formatters.makePreCommitCheck ghc;
          in
          l.nameValuePair name value
        )
        projects; # TODO optimize: will override the -profiled

      devShells = l.mapAttrValues
        (project:
          src.modules.shell.makeDevShellWith {
            extra-args = { inherit project; };
            extra-profiles = [
              src.modules.read-the-docs.makeShellProfile
              pre-commit-checks.${project.meta.haskellCompiler}.shell-profile
              (src.modules.haskell.makeShellProfileForProject project)
            ];
          }
        )
        projects;

      pre-commit-check-packages =
        l.mapAttrs' (ghc: pre-commit-check:
          l.nameValuePair "pre-commit-check-${ghc}" pre-commit-check.package
        );

      read-the-docs-packages =
        let site = src.modules.read-the-docs.makeReadTheDocsSite;
        in l.optionalAttrs (site != null) { read-the-docs-site = site; };

      per-system-outputs =
        src.modules.per-system-outputs.makePerSystemOutputsWith {
          extra-args = { inherit projects; };
        };

      haskell-flake-outputs =
        src.modules.haskell.makeAggregatedFlakeOutputsForProjects projects;

      cross-compiled-projects =
        src.modules.haskell.makeCrossCompiledAttrsetForProjects projects;

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
  


