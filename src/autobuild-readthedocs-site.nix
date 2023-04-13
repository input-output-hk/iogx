{ pkgs, sphinx-toolchain, config }:

pkgs.writeShellApplication {

  name = "autobuild-readthedocs-site";

  runtimeInputs = [
    sphinx-toolchain
  ];

  text = ''
    doc="${config.readTheDocsFolder}"
    sphinx-autobuild -j 4 -n "$doc" "$doc/_build"
  '';
}
