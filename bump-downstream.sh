cd ../antaeus
nix flake lock --update-input iogx 
git add .
git commit -m "Bump IOGX"
git push 
gh pr create --head --title "Bump IOGX" --body "Update IOGX"
gh pr merge --auto 