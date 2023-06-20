{ libnixschema, l }:

{
  haskell-project = import ./haskell-project.nix { inherit libnixschema l; };

  hydra-jobs = import ./hydra-jobs.nix { inherit libnixschema l; };

  iogx-config = import ./iogx-config.nix { inherit libnixschema l; };

  pre-commit-check = import ./pre-commit-check.nix { inherit libnixschema l; };

  shell = import ./shell.nix { inherit libnixschema l; };
}

# {
  

# }
#     importSchema = file: import (. + "/${file}.nix") { inherit libnixschema l; };
#       mkPair name = { ${file} = importSchema file };
#       l.recursiveUpdateMany (map importSchema )
#       files ="haskell-
#     in 
#       l.recursiveUpdateMany (map mkOne )
#     {




#   interface-files = [
#     "haskell-project"
#     "hydra-jobs"
#     "iogx-config"
#     "pre-commit-check"
#     "shell"
#     "read-the-docs"
#     "per-system-outputs"
#     "top-level-outputs"
#   ];

  
#   iogx-schema = 
  
#   iogx-schemas = 
#     let 
#       importSchema = file: import (. + "/${file}.nix") { inherit libnixschema l; };
#       mkPair name = { ${file} = importSchema file };
#       l.recursiveUpdateMany (map importSchema )
#       files ="haskell-
#     in 
#       l.recursiveUpdateMany (map mkOne )
#     {