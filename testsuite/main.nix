{ repoRoot, inputs, pkgs, lib, system }:

# This is an attrset of derivations that will be included in iogx's hydraJobs.
# In order to test the templates, we build each template's flake outputs.

let

  getLocalFlake = path: builtins.getFlake (builtins.toPath path);


  testsuite = {

    templates = {
      vanilla = {
        inherit (getLocalFlake ../templates/vanilla) devShells;
      };
      haskell = {
        inherit (getLocalFlake ../templates/haskell) devShells packages checks hydraJobs;
      };
    };
  };

in

testsuite

