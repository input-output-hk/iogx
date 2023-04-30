
update-pr() {
  local repo="$1"
  local root="/Users/zeme/Repos/iohk/iogx"
  cp $root/ext/$repo/flake.nix $root/ext/$repo/__repo__
  rm -r $root/ext/$repo/__repo__/nix
  cp -R $root/ext/$repo/nix $root/ext/$repo/__repo__
  cd $root/ext/$repo/__repo__ 
  nix flake lock --update-input iogx
  git add .
  git commit -m "Bump iogx flake"
  git add .
  git commit -m "Bump iogx flake"
  git push 
  cd - 
}
