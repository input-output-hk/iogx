# IOGX - Standard flake for IOG projects

This flake provides a standard environment for IOG Haskell projects.

It exports a single function `mkFlake` that will populate your flake with 
everything you need to build and develop your project, including `hydraJobs` for 
your CI.

To get started run: 
```
nix flake init --template github:zeme-wana/iogx
```
Then open the generated `./flake.nix` for documentation.

If you are migrating an existing project, refer to `template/flake.nix` inside 
this repository.