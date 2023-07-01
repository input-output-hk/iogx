export GITREV=$(git rev-parse HEAD)
export GITREV_SHORT=$(git rev-parse --short HEAD)


run() { # Thank you SO 
  printf %s "run $*? " > /dev/tty
  read answer < /dev/tty
  case $answer in
    [yY]*) "$@";;
  esac
}


bump-repo() {
  local repo="$1"
  local main_branch="$2"
  local add_label="$3"
  run cd "../$repo"
  run git stash 
  run git checkout "$main_branch"
  run git pull --rebase origin "$main_branch" 
  run git checkout -b "zeme-wana/iogx-$GITREV_SHORT"
  run git stash pop 
  run git add .
  run nix flake lock --update-input iogx 
  run git add .
  run git commit -m "Bump IOGX to $GITREV_SHORT"
  run git push --force-with-lease
  run gh pr create --title="Bump IOGX to $GITREV_SHORT" --body="Bump IOGX to [$GITREV_SHORT](https://www.github.com/input-output-hk/iogx/commit/$GITREV)"
  if [ "$add_label" != "*" ]; then
    run gh pr edit --add-label "No Changelog Required"
  fi
  run gh pr merge --auto --squash
}


bump-antaeus() {
  local repo="antaeus"
  local main_branch="main"
  local add_label="*"
  bump-repo "$repo" "$main_branch" "$add_label"
}


bump-marlowe-cardano() {
  local repo="marlowe-cardano"
  local main_branch="main"
  local add_label="No Changelog Required"
  bump-repo "$repo" "$main_branch" "$add_label"
}


bump-quickcheck-dynamic() {
  local repo="quickcheck-dynamic"
  local main_branch="main"
  local add_label="*"
  bump-repo "$repo" "$main_branch" "$add_label"
}


$1