# Scans all repositories in the input-output-hk GitHub organization and prints
# those that use iogx flake as a direct or indirect dependency.

if [ -z "$1" ]; then
  echo "usage: find-repos-that-use-iogx GITHUB_TOKEN"
  exit 1
fi

GITHUB_TOKEN="$1"

check_one_repo() {
  local org_name="$1" 
  local repo_obj="$2" 
  local repo_name="$(echo "$repo_obj" | jq -r .name)"

  local flake_lock="$(mktemp)"
  local flake_nix="$(mktemp)"

  curl \
    --max-time 5 \
    -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H 'Accept: application/vnd.github.v3.raw' \
    -L "https://api.github.com/repos/$org_name/$repo_name/contents/flake.lock" \
    > "$flake_lock"

  curl \
    --max-time 5 \
    -s \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H 'Accept: application/vnd.github.v3.raw' \
    -L "https://api.github.com/repos/$org_name/$repo_name/contents/flake.nix" \
    > "$flake_nix"

  local iogx_flake_hash="$(jq -r '.nodes.iogx.locked.rev' "$flake_lock")"

  if [[ "$iogx_flake_hash" != "null" && "$iogx_flake_hash" != "" ]]; then
    local direct_dep="$(grep -q "iogx" "$flake_nix" && echo "*" || echo "indirect")"
    local timestamp="$(jq -r '.nodes.iogx.locked.lastModified' $flake_lock)"
    local datetime=$(date -d "@$timestamp" "+%Y-%m-%d")
    printf \
      "%-64s   %s   %s   %s\n" \
      "https://www.github.com/$org_name/$repo_name" \
      "$iogx_flake_hash" \
      "$datetime" \
      "$direct_dep"
  fi 
}


check_all_repos() {
  local org_name="$1" 
  local repos=$(gh repo list "$org_name" --json name --source --limit 1000 | jq -c '.[]')

  for repo in $repos; do
    check_one_repo "$org_name" "$repo" &
  done
}


check_all_organizations() {
  check_all_repos "input-output-hk"
  check_all_repos "IntersectMBO"
}


printf "%-64s   %-40s   %-10s   %s\n" "repo" "iogx gitrev" "iogx time" "depend"
check_all_organizations | sort -rk3

wait 