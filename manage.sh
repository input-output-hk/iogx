
sh-ant() {
  nix develop --build --update-input iogx ./sc-repos/antaeus#default 
}
sh-coni() {
  nix develop --build --update-input iogx ./sc-repos/marconi#default
}
sh-qc() {
  nix develop --build --update-input iogx ./sc-repos/quickcheck-dynamic#default
}
sh-marcar() {
  nix develop --build --update-input iogx ./sc-repos/marlowe-cardano#__iogx__.default
}


req-ant() {
  nix build --update-input iogx ./sc-repos/antaeus#hydraJobs.x86_64-darwin.required
}
req-coni() {
  nix build --update-input iogx ./sc-repos/marconi#hydraJobs.x86_64-darwin.required
}
req-qc() {
  nix build --update-input iogx ./sc-repos/quickcheck-dynamic#hydraJobs.x86_64-darwin.required
}
req-marcar() {
  nix build --update-input iogx ./sc-repos/marlowe-cardano#hydraJobs.x86_64-darwin.__iogx__.required
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