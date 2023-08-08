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
      ];

      flake' =
        src.modules.per-system-outputs.makeFlakeWithPerSystemOutputs {
          inherit flake;
        };

      flake'' = flake' //
        {
          hydraJobs = src.modules.ci.makeHydraJobs;
        };
    in
    flake'';


  assembleHaskellFlake =
    let
      projects = src.modules.haskell.makeCabalProjects;

      pre-commit-checks =
        let
          mkOne = ghc: project:
            let value = src.modules.formatters.makePreCommitCheck ghc;
            in l.nameValuePair ghc value;
        in
        l.mapAttrs' mkOne projects.unprofiled;

      pre-commit-check-packages =
        let
          mkOne = ghc: pre-commit-check:
            l.nameValuePair "pre-commit-check-${ghc}" pre-commit-check.package;
        in
        l.mapAttrs' mkOne pre-commit-checks;

      read-the-docs-packages =
        let
          site = src.modules.read-the-docs.makeReadTheDocsSite;
        in
        l.optionalAttrs (site != null) { read-the-docs-site = site; };

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
          shells = l.mapAttrValues mkOne projects.profiled-and-unprofiled;
          aliases = {
            default = shells.${projects.default-prefix};
            profiled = shells.${projects.profiled-prefix};
          };
          shells-plus-aliases = shells // aliases;
        in
        if projects.count == 1 then aliases else shells-plus-aliases;

      all-haskell-flake-outputs =
        src.modules.haskell.makeAggregatedFlakeOutputsForProjects
          projects.unprofiled-and-xcompiled;

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
        (
          all-haskell-flake-outputs
        )
      ];

      flake' =
        src.modules.per-system-outputs.makeFlakeWithPerSystemOutputs {
          extra-args = { inherit projects; };
          inherit flake;
        };

      flake'' = flake' //
        {
          hydraJobs = src.modules.ci.makeHydraJobs;
        };
    in
    flake'';

in

if iogx-interface."haskell.nix".exists then
  assembleHaskellFlake
else
  assembleNonHaskellFlake 
  


