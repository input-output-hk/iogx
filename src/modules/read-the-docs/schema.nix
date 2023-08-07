validators: with validators;

{
  siteFolder.type = null-or nonempty-string;
  siteFolder.default = null;

  haddockPrologue.type = string;
  haddockPrologue.default = "";

  extraHaddockPackages.type = list-of string;
  extraHaddockPackages.default = [ ];
}
