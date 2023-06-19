{
  description = "Foo";


  inputs = {
    src.url = "github:zeme-iohk/iogx";
  };


  outputs = inputs: inputs.src.lib.mkFlake inputs;


  nixConfig = {

    extra-substituters = [
      "https://cache.iog.io"
      "https://cache.zw3rk.com"
    ];

    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];

    allow-import-from-derivation = true;
  };
}
