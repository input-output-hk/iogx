iogx-inputs:

import ./flake-dot-nix.nix iogx-inputs //
import ./mkFlake.nix iogx-inputs //
import ./mkGitRevOverlay.nix iogx-inputs //
import ./mkHaskellProject.nix iogx-inputs //
import ./mkHydraRequiredJob.nix iogx-inputs //
import ./mkShell.nix iogx-inputs //
import ./mkContainerFromCabalExe.nix iogx-inputs
