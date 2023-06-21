{ libnixschema }:

{
  haskell-project = import ./haskell-project.nix { inherit libnixschema; };

  hydra-jobs = import ./hydra-jobs.nix { inherit libnixschema; };

  iogx-config = import ./iogx-config.nix { inherit libnixschema; };

  pre-commit-check = import ./pre-commit-check.nix { inherit libnixschema; };

  shell = import ./shell.nix { inherit libnixschema; };

  per-system-outputs = import ./per-system-outputs.nix { inherit libnixschema; };

  top-level-outputs = import ./top-level-outputs.nix { inherit libnixschema; };

  read-the-docs = import ./read-the-docs.nix { inherit libnixschema; };
}
