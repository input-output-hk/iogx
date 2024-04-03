iogx-inputs:

let

  l = builtins // iogx-inputs.nixpkgs.lib;

  utils = import ../lib/utils.nix iogx-inputs;

  link = x: utils.headerToMarkDownLink x x;


  mkFlake-IN-submodule = l.types.submodule {
    options = {

      inputs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Your flake inputs.

          You almost certainly want to do `inherit inputs;` here (see the example in ${link "mkFlake"})
        '';
      };

      repoRoot = l.mkOption {
        type = l.types.path;
        description = ''
          The root of your repository (most likely `./.`).
        '';
        example = l.literalExpression "./alternative/flake.nix";
      };

      systems = l.mkOption {
        type = l.types.listOf (l.types.enum [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ]);
        description = ''
          The systems you want to build for.

          The ${link "mkFlake.<in>.outputs"} function will be called once for each system.
        '';
        default = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
        defaultText = l.literalExpression ''[ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ]'';
      };

      outputs = l.mkOption {
        type = l.types.functionTo (l.types.listOf l.types.attrs);
        example = l.literalExpression ''
          # flake.nix 
          {
            outputs = inputs: inputs.iogx.lib.mkFlake {
              outputs = import ./outputs.nix;
            };
          }

          # outputs.nix
          { repoRoot, inputs, pkgs, lib, system }:
          [
            {
              project = lib.iogx.mkHaskellProject {};
            }
            {
              packages.foo = repoRoot.nix.foo;
              devShells.foo = lib.iogx.mkShell {};
            }
            {
              hydraJobs.ghc928 = inputs.self.project.variants.ghc928.hydraJobs;
            }
          ]
        '';
        description = ''
          A function that is called once for each system in ${link "mkFlake.<in>.systems"}.

          This is the most important option as it will determine your flake outputs.

          `outputs` receives an attrset and must return a list of attrsets.

          The returned attrsets are recursively merged top-to-bottom. 

          Each of the input attributes to the `outputs` function is documented below.

          #### `repoRoot`

          Ordinarily you would use the `import` keyword to import nix files, but you can use the `repoRoot` variable instead.

          `repoRoot` is an attrset that can be used to reference the contents of your repository folder instead of using the `import` keyword.

          Its value is set to the path of ${link "mkFlake.<in>.repoRoot"}.

          For example, if this is your top-level repository folder:
          ```
          * src 
            - Main.hs 
          - cabal.project 
          * nix
            - outputs.nix
            - alpha.nix
            * bravo
              - charlie.nix 
              - india.nix
              - hotel.json
              * delta 
                - echo.nix
                - golf.txt
          ```

          Then this is how you can use the `repoRoot` attrset:
          ```nix
          # ./nix/alpha.nix
          { repoRoot, ... }:
          repoRoot."cabal.project"

          # ./nix/bravo/charlie.nix
          { repoRoot, ... }:
          repoRoot.nix.bravo."hotel.json"

          # ./nix/bravo/india.nix
          { pkgs, ... }:
          pkgs.hello

          # ./nix/bravo/delta/echo.nix
          { repoRoot, lib, ... }:
          arg1:
          { arg2 ? null }:
          lib.someFunction arg1 arg2 repoRoot.nix.bravo.delta."golf.txt"

          # ./nix/per-system-outputs.nix
          { repoRoot, inputs, pkgs, system, lib, ... }:
          { 
            packages.example = 
              let 
                a = repoRoot.nix.alpha;
                c = repoRoot.nix.bravo.charlie;
                e = repoRoot.nix.bravo.delta.echo "arg1" {};
                f = repoRoot.nix.bravo.delta."golf.txt";
                g = repoRoot.src."Main.hs";
              in
                42; 
          }
          ```

          Note that the Nix files do not need the `".nix"` suffix, while files with any other extension (e.g. `golf.txt`) must include the full name to be referenced.

          In the case of non-Nix files, internally IOGX calls `builtins.readFile` to read the contents of that file.

          > **_NOTE:_** Any nix file that is referenced this way will also receive the attrset `{ repoRoot, inputs, pkgs, system, lib }`, just like ${link "mkFlake.<in>.outputs"}.

          Using the `repoRoot` argument is optional, but it has the advantage of not having to thread the standard arguments (especially `pkgs` and `inputs`) all over the place.

          ### `inputs`

          Your flake inputs as defined in ${link "mkFlake.<in>.inputs"}.

          Note that these `inputs` have been de-systemized against the current system.
          
          This means that you can use the following syntax:
          ```nix
          inputs.n2c.packages.nix2container
          inputs.self.packages.foo
          ```
          
          In addition to the usual syntax which mentions `system` explicitely.
          ```nix 
          inputs.n2c.packages.x86_64-linux.nix2container
          inputs.self.packages.x86_64-darwin.foo
          ```

          #### `pkgs`

          A `nixpkgs` instantiated against the current system (as found in `pkgs.stdenv.system`), for each of your ${link "mkFlake.<in>.systems"}, and overlaid with goodies from `haskell.nix` and `iohk-nix`. 

          A `nixpkgs` is also available at `inputs.nixpkgs.legacyPackages` but that should *not* be used because it doesn't have the required overlays.

          You may reference `pkgs` freely to get to the legacy packages.

          #### `system`

          This is just `pkgs.stdenv.system`, which is likely to be used often.

          #### `lib`

          This is just `pkgs.lib` plus the `iogx` attrset, which contains library functions and utilities.
          
          In here you will find the following: 
          ```nix 
          lib.iogx.mkShell {}
          lib.iogx.mkHaskellProject {}
          lib.iogx.mkHydraRequiredJob {}
          lib.iogx.mkGitRevProjectOverlay {}
          ```
        '';
      };

      flake = l.mkOption {
        type = l.types.functionTo l.types.attrs;
        default = { };
        description = ''
          A function to a flake-like attrset.

          You can place additional flake outputs here, which will be recursively updated with the attrset from ${link "mkFlake.<in>.outputs"}.

          This is a good place to put system-independent values like a `lib` attrset or pure Nix values.

          Like ${link "mkFlake.<in>.outputs"}, this function takes an attrset as argument, containing both `repoRoot` and the original (non de-systemized) `inputs`.

          Note that if you use `repoRoot` to reference nix files in this context, the nix files must also be functions from an `{ repoRoot, inputs }` attrset.
        '';
        example = l.literalExpression ''
          { repoRoot, inputs }:
          {
            lib.bar = _: null;

            packages.x86_64-linux.foo = null;
            devShells.x86_64-darwin.bar = null;

            networks = {
              prod = { };
              dev = { };
            };
          }
        '';
      };

      nixpkgsArgs = l.mkOption {
        type = l.types.attrs;
        description = ''
          Internally, IOGX calls `import inputs.nixpkgs {}` for each of your ${link "mkFlake.<in>.systems"}.

          Using `nixpkgsArgs` you can provide an additional `config` attrset and a list of `overlays` to be appended to nixpkgs.
        '';
        default = {
          config = { };
          overlays = [ ];
        };
        example = l.literalExpression ''
          # flake.nix
          {
            outputs = inputs: inputs.iogx.lib.mkFlake {
              nixpkgsArgs.overlays = [(self: super: { 
                acme = super.callPackage ./nix/acme.nix { }; 
              })];
              nixpkgsArgs.config.permittedInsecurePackages [
                "python-2.7.18.6"
              ];
            };
          }
        '';
        defaultText = l.literalExpression ''
          { 
            config = { }; 
            overlays = [ ]; 
          }
        '';
      };

      debug = l.mkOption {
        type = l.types.bool;
        default = false;
        description = ''
          If enabled, IOGX will trace debugging info to standard output.
        '';
      };
    };
  };


  mkFlake-IN = l.mkOption {
    type = mkFlake-IN-submodule;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkFlake-OUT = l.mkOption {
    type = l.types.raw;
    description = ''
      # Not Rendered In Docs
    '';
  };


  mkFlake = l.mkOption {
    type = utils.mkApiFuncOptionType mkFlake-IN.type mkFlake-OUT.type;
    description = ''
      The `inputs.iogx.lib.mkFlake` function takes an attrset of options and returns an attrset of flake outputs.

      In this document, options for the input attrset are prefixed by `mkFlake.<in>`.
    '';
    example = l.literalExpression ''
      # flake.nix
      {
        outputs = inputs: inputs.iogx.lib.mkFlake {
          inherit inputs;
          repoRoot = ./.;
          debug = false;
          nixpkgsArgs = {};
          systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
          outputs = { repoRoot, inputs, pkgs, lib, system }: [];
        };
      }
    '';
  };

in

{
  inherit mkFlake;
  "mkFlake.<in>" = mkFlake-IN;
}
