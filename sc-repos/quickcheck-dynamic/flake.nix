{
  description = "QuickCheck Dynamic";

  inputs = {
    iogx.url = "path:../../.";
  };

  outputs = inputs:
    inputs.iogx.mkFlake {
      inherit inputs;
      repoRoot = inputs.iogx.inputs.quickcheck-dynamic;
      shellName = "quickcheck-dynamic";
      haskellProjectFile = import ./nix/haskell-project.nix;
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
    allow-import-from-derivation = "true";
  };

}
