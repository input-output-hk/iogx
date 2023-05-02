{
  description = "Marconi";

  inputs = {
    iogx.url = "path:../../.";
    iogx.inputs.haskell-nix.url = "github:input-output-hk/haskell.nix/3473e3c9955954a548f28c97d5d47115c5b17b53";
    iogx.inputs.hackage.url = "github:input-output-hk/hackage-nix/1ea938efb94c8d7ad4f6933efffaccd0fbc47cda";
    iogx.inputs.CHaP.url = "github:input-output-hk/cardano-haskell-packages/e8dcdade66871b3b63d863667e410696b55de9b2";
  };

  outputs = inputs:
    inputs.iogx.mkFlake {
      inherit inputs;
      repoRoot = inputs.iogx.inputs.marconi;
      shellName = "marconi";
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
