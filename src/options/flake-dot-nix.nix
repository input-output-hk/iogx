iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToMarkDownLink x x;

  flake-dot-nix-submodule = l.types.submodule {
    options = {
      description = l.mkOption {
        type = l.types.str;
        description = ''
          Arbitrary description for the flake. 

          This string is displayed when running `nix flake info` and other flake 
          commands. 

          It can be a short title for your project. 
        '';
        example = l.literalExpression ''
          # flake.nix 
          { 
            description = "My Haskell Project";
          }
        '';
      };

      inputs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Your flake *must* define `iogx` among its inputs. 

          In turn, IOGX manages the following inputs for you: 
          [CHaP](https://github.com/input-output-hk/cardano-haskell-packages), 
          [haskell.nix](https://github.com/input-output-hk/haskell.nix), 
          [nixpkgs](https://github.com/NixOS/nixpkgs), 
          [hackage.nix](https://github.com/input-output-hk/hackage.nix), 
          [iohk-nix](https://github.com/input-output-hk/iohk-nix), 
          [sphinxcontrib-haddock](https://github.com/michaelpj/sphinxcontrib-haddock), 
          [pre-commit-hooks-nix](https://github.com/cachix/pre-commit-hooks.nix), 
          [haskell-language-server](https://github.com/haskell/haskell-language-server), 
          [easy-purescript-nix](https://github.com/justinwoo/easy-purescript-nix). 

          If you find that you want to use a different version of some of the 
          implicit inputs listed above, for instance because IOGX has not been 
          updated, or because you need to test against a specific branch, you 
          can use the `follows` syntax like in the example above.

          Note that the Haskell template `flake.nix` does this by default with 
          `CHaP`, `hackage.nix` and `haskell.nix`.

          It is of course possible to add other inputs (not already managed by 
          IOGX) in the normal way. 

          For example, to add `nix2container` and `cardano-world`:

          ```nix
          inputs = {
            iogx.url = "github:inputs-output-hk/iogx";
            n2c.url = "github:nlewo/nix2container";
            cardano-world.url = "github:input-output-hk/cardano-world";
          };
          ```

          If you need to reference the inputs managed by IOGX in your flake, you 
          may use this syntax:

          ```nix
          { inputs, ... }:
          {
            nixpkgs = inputs.iogx.inputs.nixpkgs;
            CHaP = inputs.iogx.inputs.CHaP;
            haskellNix = inputs.iogx.inputs.haskell-nix;
          }
          ```

          If you are using the `follows` syntax for some inputs, you can avoid 
          one level of indirection when referencing those inputs:
          ```nix
          { inputs, ... }:
          {
            nixpkgs = inputs.nixpkgs;
            CHaP = inputs.CHaP;
            haskellNix = inputs.haskell-nix;
          }
          ```

          If you need to update IOGX (or any other input) you can do it the 
          normal way:

          ```bash
          nix flake lock --update-input iogx 
          nix flake lock --update-input haskell-nix 
          nix flake lock --update-input hackage 
          nix flake lock --update-input CHaP 
          ```
        '';
        example = l.literalExpression ''
          # flake.nix inputs for Haskell Projects
          { 
            inputs = {
              iogx = {
                url = "github:input-output-hk/iogx";
                inputs.hackage.follows = "hackage";
                inputs.CHaP.follows = "CHaP";
                inputs.haskell-nix.follows = "haskell-nix";
                inputs.nixpkgs.follows = "haskell-nix/nixpkgs-2305";
              };

              hackage = {
                url = "github:input-output-hk/hackage.nix";
                flake = false;
              };

              CHaP = {
                url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
                flake = false;
              };

              haskell-nix = {
                url = "github:input-output-hk/haskell.nix";
                inputs.hackage.follows = "hackage";
              };
            };
          }

          # flake.nix inputs for Vanilla Projects
          { 
            inputs = {
              iogx.url = "github:input-output-hk/iogx";
            };
          }       
        '';
      };

      outputs = l.mkOption {
        type = l.types.functionTo l.types.attrs;
        description = ''
          Your flake `outputs` are produced using ${link "mkFlake"}.
        '';
        example = l.literalExpression ''
          # flake.nix
          {
            outputs = inputs: inputs.iogx.lib.mkFlake {

              inherit inputs;

              repoRoot = ./.;

              outputs = import ./nix/outputs.nix;

              # systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];

              # debug = false;

              # nixpkgsArgs = {
              #   config = {};
              #   overlays = [];
              # };

              # flake = {};
            };
          }
        '';
      };

      nixConfig = l.mkOption {
        type = l.types.attrs;
        description = ''
          Unless you know what you are doing, you should not change `nixConfig`.

          You could always add new `extra-substituters` and `extra-trusted-public-keys`, but do not delete the existing ones, or you won't have access to IOG caches. 

          For the caches to work properly, it is sufficient that the following two lines be included in your `/etc/nix/nix.conf`:
          ```txt
          trusted-users = USER
          experimental-features = nix-command flakes
          ```
          Replace `USER` with the result of running `whoami`. 

          You may need to reload the nix daemon on Darwin for changes to `/etc/nix/nix.conf` to take effect:
          ```bash
          sudo launchctl stop org.nixos.nix-daemon
          sudo launchctl start org.nixos.nix-daemon
          ```
          Leave `allow-import-from-derivation` set to `true` for `haskell.nix` for work correctly.

          If Nix starts building `GHC` or other large artifacts that means that your caches have not been configured properly.
        '';
        example = l.literalExpression ''
          # flake.nix 
          { 
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
        '';
      };
    };
  };

  flake-dot-nix = l.mkOption {
    type = flake-dot-nix-submodule;
    description = ''
      The `flake.nix` file for your project.

      For [Haskell Projects](../templates/haskell/flake.nix):
      ```bash
      nix flake init --template github:input-output-hk/iogx#haskell
      ```

      For [Other Projects](../templates/vanilla/flake.nix):
      ```bash
      nix flake init --template github:input-output-hk/iogx#vanilla
      ```

      Below is a description of each of its attributes.
    '';
  };

in { "flake.nix" = flake-dot-nix; }
