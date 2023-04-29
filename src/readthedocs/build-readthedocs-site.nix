{ pkgs, sphinx-toolchain, flakeopts }:

pkgs.writeShellApplication {

  name = "build-readthedocs-site";

  runtimeInputs = [
    sphinx-toolchain
  ];

  text = ''
    doc="${flakeopts.readTheDocsFolder}"
    sphinx-build -j 4 -n "$doc" "$doc/_build"
  '';
}
