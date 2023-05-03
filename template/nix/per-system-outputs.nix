# The actual flake outputs, per system.
# 
# This is where you define extra `packages`, `checks`, `apps`, etc..., or any 
# non-standard flake output like `nomadTasks` or `operables`.
#
# Remember that you can access these using `self` from `inputs` or 
# `systemized-inputs`, for example:
#   `inputs.self.nomadTasks`
#   `systemized-inputs.self.nomadTasks.x86_64-linux`
#
# iogx will union its outputs with yours, and yours will take precedence.
{
  # Desystemized merged inputs.
  # All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the 
  # inputs defined in your flake. You will also find the `self` attribute here.
  # These inputs have been desystemized against the current system.
  inputs

  # Non-desystemized merged inputs.
  # All the inputs from iogx (e.g. CHaP, haskell-nix, etc..) unioned with the 
  # inputs defined in your flake. You will also find the `self` argument here. 
  # These inputs have not been desystemized, they are the original `inputs` from
  # iogx and your `flake.nix`.
, systemized-inputs

  # The very attrset passed to `inputs.iogx.mkFlake` in your `flake.nix`.
, flakeopts

  # Desystemized legacy nix packages configured against `haskell.nix`.
  # NEVER use the `nixpkgs` coming from `inputs` or `systemized-inputs`!
, pkgs
}:

let
  system = pkgs.stdenv.system;
in

{
  packages = { };

  devShells = { };

  checks = { };

  apps = { };

  # operables = {};

  # oci-images = {};

  # nomadTasks = {};

  # anything-else = {};
}
