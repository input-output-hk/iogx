# These outputs are system-independent and will end up in the same layer as the 
# standard `packages`, `apps`, `devShells`, etc...
# They will be avaialble via `inputs.self.*` or `systemized-inputs.self.*`.

{
  # Non-desystemized merged inputs.
  # All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the 
  # inputs defined in your flake. You will also find the `self` argument here. 
  # These inputs have not been desystemized, they are the original `inputs` from
  # iogx and your `flake.nix`. 
  systemized-inputs

  # The very config passed as second argument to `inputs.iogx.mkFlake` in your 
  # `flake.nix`.
, iogx-config
}:

{
  # networks = {};

  # globals = {};
}
