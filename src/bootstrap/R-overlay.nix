final: prev: {

  # The haskell inline-r package depends on internals of the R
  # project that have been hidden in R 4.2+. 
  # See https://github.com/tweag/HaskellR/issues/374
  R_4_1_3 = final.R.overrideDerivation (old: rec {
    version = "4.1.3";
    patches = [ ]; # upstream patches will most likely break this build, as they are specific to a different version.
    src = final.fetchurl {
      url = "https://cran.r-project.org/src/base/R-${final.lib.versions.major version}/${old.pname}-${version}.tar.gz";
      sha256 = "sha256-Ff9bMzxhCUBgsqUunB2OxVzELdAp45yiKr2qkJUm/tY=";
    };
  });

  rPackages = prev.rPackages.override {
    overrides = ({
      hexbin = prev.rPackages.hexbin.overrideDerivation (attrs: {
        nativeBuildInputs = attrs.nativeBuildInputs ++ [ prev.libiconv ];
        buildInputs = attrs.buildInputs ++ [ prev.libiconv ];
      });
    });
  };

  R = prev.R.overrideAttrs (oldAttrs: {
    # Backport https://github.com/NixOS/nixpkgs/pull/99570
    prePatch = prev.lib.optionalString prev.stdenv.isDarwin ''
      substituteInPlace configure --replace "-install_name libRblas.dylib" "-install_name $out/lib/R/lib/libRblas.dylib"
      substituteInPlace configure --replace "-install_name libRlapack.dylib" "-install_name $out/lib/R/lib/libRlapack.dylib"
      substituteInPlace configure --replace "-install_name libR.dylib" "-install_name $out/lib/R/lib/libR.dylib"
    '';
  });

}
