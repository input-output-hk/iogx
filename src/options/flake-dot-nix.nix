iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToLocalMarkDownLink x x;


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
          ```

          When working with Haskell, the package snapshots in `hackage` and
          `CHaP` are updated together, while `haskell-nix` provides the 
          infrastructure necessary to build the project with nix.

          If you cannot enter the nix shell after updating the `index-state` in 
          your `cabal.project`, you might need to update `hackage` and `CHaP`:
          ```
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

              # systems = [ "x86_64-linux" "x86_64-darwin" ];

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

          You could add new `extra-substituters` and 
          `extra-trusted-public-keys`, but do not delete the existing ones, or 
          you won't have access to our binary caches. 
         
          Leave `allow-import-from-derivation` set to `true` for `haskell.nix` 
          for work correctly.

          Make sure that you have configured your nix installation correctly by 
          following the instructions in ${link "flake.nix"}.
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
      This section of the manual documents the `flake.nix` file, which is the 
      entrypoint of all nix code, and should be located in the top-level folder 
      of your repository. 

      Here you will also find instructions on how to install, upgrade and 
      configure nix; how to enable access the IOG binary caches, and how to keep 
      your flake inputs up to date.

      If you don't have nix installed, follow the instructions on the 
      [official website](https://nixos.org/download).

      If you already have nix installed, you are advised to 
      [upgrade](https://nixos.org/manual/nix/stable/installation/upgrading) to 
      the latest version.

      Once you have installed nix, you ought to enable access to our binary 
      caches. To do so, it is sufficient that the following two lines be 
      included in your `/etc/nix/nix.conf`:
      ```txt
      trusted-users = USER
      experimental-features = nix-command flakes
      ```
      **Replace `USER` with the result of running `whoami`.**
      
      If you are running on Apple Silicon, append the following line to your 
      `/etc/nix/nix.conf`:
      ```txt
      extra-platforms = x86_64-darwin aarch64-darwin
      ```
      And remember to add the flag `--system x86_64-darwin` to all your nix 
      commands, if no `aarch64-darwin` derivation is available:
      ```bash
      nix (develop|build|run|check) --system x86_64-darwin # Will use the x86_64-darwin derivation
      nix (develop|build|run|check) # Will use the aarch64-darwin derivation, if available
      ```

      You may need to reload the nix daemon on Darwin for changes to 
      `/etc/nix/nix.conf` to take effect:
      ```bash
      sudo launchctl stop org.nixos.nix-daemon
      sudo launchctl start org.nixos.nix-daemon
      ```

      When working with IOG projects, you will want to make sure that you do 
      have access to our binary caches. If nix starts building `GHC` or other 
      large artifacts, that means that your caches have not been configured 
      properly and you should review this documentation carefully.

      Once you have nix installed and configured, you can generate a 
      `flake.nix` file using one of the available templates:

      For [Haskell Projects](../templates/haskell/flake.nix):
      ```bash
      nix flake init --template github:input-output-hk/iogx#haskell
      ```

      For [Other Projects](../templates/vanilla/flake.nix):
      ```bash
      nix flake init --template github:input-output-hk/iogx#vanilla
      ```
      
      When working with Haskell projects, you will want to know how to keep your 
      flake inputs up to date. You will find that information in the 
      documentation for the ${utils.headerToLocalMarkDownLink "inputs" "flake.nix.inputs"} attribute.
    '';
  };


in

{
  "flake.nix" = flake-dot-nix;
}

