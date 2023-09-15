{ repoRoot, inputs, pkgs, lib, system }:
let 
  cabalProject = repoRoot.nix.project;

  ghc8107 = cabalProject.iogx;
  # ghc8107-profiled = cabalProject.projectVariants.profiled.iogx;
  # ghc928 = cabalProject.projectVariants.ghc928.iogx;
  # ghc964 = cabalProject.projectVariants.ghc964.iogx;
in 
[
  {
    inherit cabalProject;
  }
  {
    devShells.default = ghc8107.devShell;
    # devShells.profiled = ghc8107-profiled.devShell;

    # devShells.ghc928 = ghc928.devShell;
    # devShells.ghc964 = ghc964.devShell;
  }
  {
    packages = ghc8107.packages;
  }
  {
    apps = ghc8107.apps;
  }
  {
    checks = ghc8107.checks;
  }
  {
    packages.read-the-docs = ghc8107.read-the-docs;
    packages.pre-commit-check = ghc8107.pre-commit-check;
  }
  {
    hydraJobs.ghc8107 = ghc8107.hydraJobs;
    # hydraJobs.ghc928 = ghc928.hydraJobs;
    # hydraJobs.ghc964 = ghc964.hydraJobs;
    hydraJobs.read-the-docs = ghc8107.read-the-docs;
    hydraJobs.pre-commit-check = ghc8107.pre-commit-check;
  }

  # (lib.optionalAttrs (system == "x86_64-linux") 
  # {
  #   hydraJobs.ming64 = cabalProject.projectCross.mingwW64.iogx.hydraJobs;
  #   hydraJobs.musl64 = cabalProject.projectCross.musl64.iogx.hydraJobs;
  # })
]