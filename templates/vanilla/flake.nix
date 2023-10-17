{
  description = "Change the description field in your ./flake.nix";


  inputs = {
    iogx.url = "github:input-output-hk/iogx";
  };


  outputs = inputs: inputs.iogx.lib.mkFlake {

    inherit inputs;

    repoRoot = ./.;

    outputs = import ./nix/outputs.nix;

    # systems = [ "x86_64-linux" "x86_64-darwin" ];

    # debug = false;

    # nixpkgsArgs = {
    #   config = {};
    #   overlays = [];
    # };

    # flake = {};
  };


  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = true;
  };
}
