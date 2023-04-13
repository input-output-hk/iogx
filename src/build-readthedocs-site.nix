{ pkgs, sphinx-toolchain, config }:

pkgs.writeShellApplication {

  name = "build-readthedocs-site";

  runtimeInputs = [
    sphinx-toolchain
  ];

  text = ''
    doc="${config.readTheDocsFolder}"
    sphinx-build -j 4 -n "$doc" "$doc/_build"
  '';
}
