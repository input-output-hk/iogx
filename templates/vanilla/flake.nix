# Docs for this file: https://github.com/input-output-hk/iogx/blob/main/doc/api.md#flakenix
{
  description = "Change the description field in your flake.nix";

  inputs = { iogx.url = "github:input-output-hk/iogx"; };

  # Docs for mkFlake: https://github.com/input-output-hk/iogx/blob/main/doc/api.md#mkflake
  outputs = inputs:
    inputs.iogx.lib.mkFlake {

      inherit inputs;

      repoRoot = ./.;

      outputs = import ./nix/outputs.nix;

      # systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];

      # debug = false;

      # nixpkgsArgs = {
      #   config = {};
      #   overlays = [];
      # };

      # flake = { repoRoot, inputs }: {};
    };

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys =
      [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    allow-import-from-derivation = true;
  };
}
