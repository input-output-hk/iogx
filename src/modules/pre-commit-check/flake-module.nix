{ src, ... }:

let 

  flake-module = {

    forEachProject = { project }: 
      let 
        ghc = project.meta.haskellCompiler;
        pre-commit-check = src.modules.pre-commit-check.make-package { inherit ghc; };
        devshell-profile = src.modules.pre-commit-check.devshell-profile { inherit pre-commit-check; };
      in 
        {
          packages.pre-commit-check-${ghc} = pre-commit-check;
          hydraJobs.packages.pre-commit-check-${ghc} = pre-commit-check;
          __iogx__.devshellProfiles.pre-commit-check = devshell-profile;
        };
  };

in 

  flake-module
