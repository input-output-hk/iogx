
export IOGX_UPDATE_INPUT="--update-input iogx"


sh-ant() {
  nix develop --build $IOGX_UPDATE_INPUT ./sc-repos/antaeus#default 
}
sh-coni() {
  nix develop --build $IOGX_UPDATE_INPUT ./sc-repos/marconi#default
}
sh-qc() {
  nix develop --build $IOGX_UPDATE_INPUT ./sc-repos/quickcheck-dynamic#default
}
sh-marcar() {
  nix develop --build $IOGX_UPDATE_INPUT ./sc-repos/marlowe-cardano#__iogx__.default
}


req-ant() {
  nix build $IOGX_UPDATE_INPUT ./sc-repos/antaeus#hydraJobs.x86_64-darwin.required
}
req-coni() {
  nix build $IOGX_UPDATE_INPUT ./sc-repos/marconi#hydraJobs.x86_64-darwin.required
}
req-qc() {
  nix build $IOGX_UPDATE_INPUT ./sc-repos/quickcheck-dynamic#hydraJobs.x86_64-darwin.required
}
req-marcar() {
  nix build $IOGX_UPDATE_INPUT ./sc-repos/marlowe-cardano#hydraJobs.x86_64-darwin.__iogx__.required
}


testolino-fast() {
  export IOGX_UPDATE_INPUT=""
  testolino
}


testolino() {
  sh-ant
  sh-coni
  sh-qc
  sh-marcar

  req-ant
  req-coni
  req-qc
  req-marcar
}


resource() {
  source ./manage.sh
}