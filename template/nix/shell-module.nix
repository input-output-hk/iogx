# Your development shell is defined here.
# You can add packages, scripts, envvars, and a shell hook.

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

{
  # Add any extra packages that you want in your shell here.
  packages = [
    # pkgs.hello 
    # pkgs.curl 
    # pkgs.sqlite3 
  ];

  # Add any script that you want in your shell here.
  # `scripts` is an attrset where each attribute name is the script name, and 
  # the attribute value is an attrset `{ exec, description, enabled }`.
  # `description` is optional will appear next to the script name.
  # `exec` is bash code to be executed when the script is run.
  # `enabled` is optional, defaults to true if not set, and can be used to 
  # include scripts conditionally, for example:
  #   { enabled = pkgs.stdenv.system != "x86_64-darwin"; }
  scripts = {
    foobar = {
      exec = ''
        # Bash code to be executed whenever the script `foobar` is run.
        echo "Delete me from your shell-module.nix!"
      '';
      description = ''
        You might want to delete the foobar script.
      '';
      enabled = true;
    };
  };

  # Add your environment variables here.
  # For each key-value pair the bash line:
  # `export NAME="VALUE"` will be appended to `enterShell`. 
  env = {
    NAME = VALUE;
  };

  enterShell = ''
    # Bash code to be executed when you enter the shell.
  '';
}
