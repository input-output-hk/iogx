{
  description = "Marlowe Cardano implementation";

  inputs = {
    iogx.url = "path:../../.";
  };

  outputs = inputs:
    inputs.iogx.mkFlake {
      inherit inputs;
      repoRoot = inputs.iogx.inputs.marlowe-cardano;
      enablePreCommitCheck = false;
      shellName = "marlowe-cardano";
      haskellProjectFile = import ./__iogx__/haskell-project.nix;
      perSystemOutputs = import ./__iogx__/per-system-outputs.nix;
      shellModule = import ./__iogx__/shell-module.nix;
      flakeOutputsPrefix = "__iogx__";
    };


  nixConfig = {
    extra-substituters = [
      # TODO: spongix
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
    # post-build-hook = "./upload-to-cache.sh";
    allow-import-from-derivation = "true";
  };

}
