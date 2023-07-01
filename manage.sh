set -e 


run() { # Thank you SO 
  printf %s "IOGX: $* [y/n]" > /dev/tty
  read answer < /dev/tty
  case $answer in
    [yY]*) "$@";;
  esac
}


bump-repo() {
  local repo="$1"
  local main_branch="$2"
  local add_label="$3"
  local branch_magic="$4"

  local bump_branch="zeme-wana/iogx-bump-$branch_magic"
  echo "IOGX: preparing bump branch '$bump_branch'"

  cd "../$repo"

  if git branch -r --merged | grep -q "$bump_branch"; then 
    echo "IOGX: bump branch '$bump_branch' has already been merged"
    echo "IOGX: call bump-repo with a different \$branch_magic"
    return 1 
  fi 

  run git stash 
  run git checkout "$main_branch"
  run git pull --rebase origin "$main_branch" 

  if git show-ref -q --heads "$bump_branch"; then
    echo "IOGX: checking out bump branch '$bump_branch'"
    run git checkout "$bump_branch"
  else 
    echo "IOGX: need to create new bump branch '$bump_branch'"
    run git checkout -b "$bump_branch"
  fi 

  run git stash pop 
  run git add .
  run nix flake lock --update-input iogx 
  run git add .

  local iogx_remote="$(git ls-remote https://www.github.com/input-output-hk/iogx refs/heads/main)"
  local iogx_head="${iogx_remote[0]}"

  run git commit -m "Bump IOGX to $iogx_head"
  run git push --force

  local pr_state="$(gh pr view --json state --jq .state)"

  if [ "$pr_state" -eq "OPEN" ]; then 
    echo "IOGX: open PR already exists for '$bump_branch': modifying title and body" 
    run gh pr edit --body="Bump IOGX to [$iogx_head](https://www.github.com/input-output-hk/iogx/commit/$iogx_head)"
    run gh pr edit --title="Bump IOGX to $iogx_head"
  else 
    echo "IOGX: need to create auto-merging PR for '$bump_branch'" 
    run gh pr create --title="Bump IOGX to $iogx_head" --body="Bump IOGX to [$iogx_head](https://www.github.com/input-output-hk/iogx/commit/$iogx_head)"
    if [ "$add_label" != "*" ]; then
      run gh pr edit --add-label "No Changelog Required"
    fi
    run gh pr merge --auto --squash
  fi 
}


bump-antaeus() {
  local branch_magic="$1"
  local repo="antaeus"
  local main_branch="main"
  local add_label="*"
  bump-repo "$repo" "$main_branch" "$add_label" "$branch_magic"
}


bump-marlowe-cardano() {
  local branch_magic="$1"
  local repo="marlowe-cardano"
  local main_branch="main"
  local add_label="No Changelog Required"
  bump-repo "$repo" "$main_branch" "$add_label" "$branch_magic"
}


bump-quickcheck-dynamic() {
  local branch_magic="$1"
  local repo="quickcheck-dynamic"
  local main_branch="main"
  local add_label="*"
  bump-repo "$repo" "$main_branch" "$add_label" "$branch_magic"
}


bump-marconi() {
  local branch_magic="$1"
  local repo="marconi"
  local main_branch="main"
  local add_label="*"
  bump-repo "$repo" "$main_branch" "$add_label" "$branch_magic"
}


bump-all() {
  local branch_magic="$1"
  bump-antaeus "$branch_magic"
  bump-marlowe-cardano "$branch_magic"
  bump-quickcheck-dynamic "$branch_magic"
  bump-marconi "$branch_magic"
}


$1 "${@:2}"