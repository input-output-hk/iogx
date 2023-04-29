{ pkgs, sphinx-toolchain, flakeopts }:

pkgs.writeShellApplication {

  name = "autobuild-readthedocs-site";

  runtimeInputs = [
    sphinx-toolchain
  ];

  text = ''
    doc="${flakeopts.readTheDocsFolder}"
    sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
  '';
}
