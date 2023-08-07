validators: with validators;

let

  hook-schema = {
    enable.type = bool;
    enable.default = false;

    extraOptions.type = string;
    extraOptions.default = "";
  };


  default-hook = {
    enable = false;
    extraOptions = "";
  };

in

{
  cabal-fmt.type = schema hook-schema;
  cabal-fmt.default = default-hook;

  stylish-haskell.type = schema hook-schema;
  stylish-haskell.default = default-hook;

  shellcheck.type = schema hook-schema;
  shellcheck.default = default-hook;

  prettier.type = schema hook-schema;
  prettier.default = default-hook;

  editorconfig-checker.type = schema hook-schema;
  editorconfig-checker.default = default-hook;

  nixpkgs-fmt.type = schema hook-schema;
  nixpkgs-fmt.default = default-hook;

  png-optimization.type = schema hook-schema;
  png-optimization.default = default-hook;

  fourmolu.type = schema hook-schema;
  fourmolu.default = default-hook;

  hlint.type = schema hook-schema;
  hlint.default = default-hook;

  hindent.type = schema hook-schema;
  hindent.default = default-hook;
}
