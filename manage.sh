export GITREV=$(git rev-parse HEAD)
export GITREV_SHORT=$(git rev-parse --short HEAD)

bump-repo() {
  local repo="$1"
  local main_branch="$2"
  local add_label="$3"
  cd "../$repo"
  git stash 
  git checkout "$main_branch"
  git pull --rebase origin "$main_branch" 
  git checkout -b "zeme-wana/bump-iogx-$GITREV_SHORT"
  nix flake lock --update-input iogx 
  git add .
  git commit -m "Bump IOGX to $GITREV_SHORT"
  git push --force-with-lease
  gh pr create --title="Bump IOGX to $GITREV_SHORT" --body="Bump IOGX to [$GITREV](https://www.github.com/input-output-hk/iogx/commit/$GITREV)"
  if [ "$add_label" != "*" ]; then
    gh pr edit --add-label "No Changelog Required"
  fi
  gh pr merge --auto --squash
  git stash pop
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

update-the-template() {
  local url="https://www.github.com/input-output-hk/iogx/tree/$GITREV_SHORT/MANUAL.md"
  local needle=""
}

$1