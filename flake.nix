{
  description = "Flake Templates for Projects at IOG";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in 
      {
        devShells.default = pkgs.mkShell {
          name = "iogx";
          packages = [
            pkgs.jq
            pkgs.git
            pkgs.github-cli
            pkgs.nix-prefetch-github
          ];
          shellHook = ''
            export PS1="\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] "
          '';
        };

        hydraJobs = rec {

          templates.haskell = 
            let
              flake = (import inputs.flake-compat { src = ./templates/haskell; }).defaultNix;
            in
            {
              devShells = flake.devShells.${system};
              packages = flake.packages.${system};
              hydraJobs = flake.hydraJobs.${system};
            };

          required = templates.haskell.hydraJobs.required;
        };

        flake = rec {
          templates.default = templates.haskell;

          templates.haskell = {
            path = ./templates/haskell;
            description = "Flake Template for Haskell Projects";
            welcomeText = ''
              # Flake Template for Haskell Projects
              Edit your cabal.project and run `nix develop` to enter the shell.
            '';
          };
        };
      });

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
    accept-flake-config = true;
  };
}
