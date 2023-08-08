{ pkgs, l, inputs, inputs', nix, system, iogx-interface, __flake__, ... }:

let

  ci = iogx-interface."ci.nix".load { inherit nix inputs inputs' pkgs l system; };


  initial-jobset = l.optionalAttrs ci.includeDefaultOutputs {
    packages = l.getAttrWithDefault "packages" { } __flake__;
    checks = l.getAttrWithDefault "checks" { } __flake__;
    devShells = l.getAttrWithDefault "devShells" { } __flake__;
  };


  # TODO check ci.includedPaths and ci.excludedPaths do not contain hydraJobs
  addIncludedPaths =
    l.recursiveUpdate (l.restrictManyAttrsByPathString ci.includedPaths __flake__);


  removeExcludedPaths = l.deleteManyAttrsByPathString ci.excludedPaths;


  cleanJobs = l.filterAttrsRecursive (name: _: name != "recurseForDerivations");


  addRequiredJob = jobs:
    let
      required-job = pkgs.releaseTools.aggregate {
        name = "required";
        meta.description = "All jobs required to pass CI";
        constituents = l.collect l.isDerivation jobs;
      };
    in
    jobs // { required = required-job; };


  hydra-jobs =
    l.composeManyLeft [
      addIncludedPaths
      removeExcludedPaths
      cleanJobs
      addRequiredJob
    ]
      initial-jobset;


  is-supported-system =
    l.elem pkgs.stdenv.system [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];


  hydraJobs = l.optionalAttrs is-supported-system hydra-jobs;

in

hydraJobs
