
# https://www.github.com/InsersectMBO/plutus                              open -a Safari https://github.com/IntersectMBO/plutus/pull/5727     
# https://www.github.com/InsersectMBO/plutus-apps                         open -a Safari https://github.com/IntersectMBO/plutus-apps/pull/1119     
# https://www.github.com/input-output-hk/marlowe-ts-sdk                   open -a Safari https://github.com/input-output-hk/marlowe-ts-sdk/pull/176     
# https://www.github.com/input-output-hk/marlowe-agda                     open -a Safari https://github.com/input-output-hk/marlowe-agda/pull/4        
# https://www.github.com/input-output-hk/marconi                          open -a Safari https://github.com/input-output-hk/marconi/pull/295  
# https://www.github.com/input-output-hk/dapps-certification              open -a Safari https://github.com/input-output-hk/dapps-certification/pull/135  
# https://www.github.com/input-output-hk/marconi-sidechain-node           open -a Safari https://github.com/input-output-hk/marconi-sidechain-node/pull/14
# https://www.github.com/input-output-hk/marlowe                          open -a Safari https://github.com/input-output-hk/marlowe/pull/199       
# https://www.github.com/input-output-hk/quickcheck-dynamic               open -a Safari https://github.com/input-output-hk/quickcheck-dynamic/pull/64
# https://www.github.com/input-output-hk/marlowe-token-plans              open -a Safari https://github.com/input-output-hk/marlowe-token-plans/pull/37
# https://www.github.com/input-output-hk/marlowe-runner                   open -a Safari https://github.com/input-output-hk/marlowe-runner/pull/33      
# https://www.github.com/input-output-hk/marlowe-plutus                   open -a Safari https://github.com/input-output-hk/marlowe-plutus/pull/15
# https://www.github.com/input-output-hk/marlowe-payouts                  open -a Safari https://github.com/input-output-hk/marlowe-payouts/pull/29    
# https://www.github.com/input-output-hk/marlowe-cardano                  open -a Safari https://github.com/input-output-hk/marlowe-cardano/pull/801  
# https://www.github.com/input-output-hk/stablecoin-plutus                open -a Safari https://github.com/input-output-hk/stablecoin-plutus/pull/463
# https://www.github.com/input-output-hk/quickcheck-contractmodel         open -a Safari https://github.com/input-output-hk/quickcheck-contractmodel/pull/33
# https://www.github.com/input-output-hk/antaeus                          open -a Safari https://github.com/input-output-hk/antaeus/pull/78   
# https://www.github.com/input-output-hk/marlowe-playground               open -a Safari https://github.com/input-output-hk/marlowe-playground/pull/65
# https://www.github.com/input-output-hk/flake-release-tool               DENIED
# https://www.github.com/input-output-hk/sidechains-bridge-backend        INDIRECT
# https://www.github.com/input-output-hk/marlowe-atala-scholarship        INDIRECT
# https://www.github.com/input-output-hk/iogx                             INDIRECT
# https://www.github.com/input-output-hk/marlowe-starter-kit              INDIRECT


bump_repo() {
  local repo_branch="$1"
  local repo_folder="$2"
  local repo_url="$2"

  cd "../$repo_folder"
  git stash
  git checkout "$repo_branch"
  find . -name "*.DS_Store" -delete
  git pull
  git checkout -b iogx-bump-2024-01-17
  git checkout iogx-bump-2024-01-17
  git pull --rebase origin "$repo_branch"
  # sed -i '' 's|github:input-output-hk/iogx|github:input-output-hk/iogx?ref=custom-precommit-hooks|' flake.nix
  nix flake lock --update-input iogx
  git add .
  git commit -m "Bump IOGX 2024-01-17" --no-verify
  git push
  # gh pr create --title "Bump IOGX 2024-01-17" --body "" --draft 
  # --label "No Changelog Required" 
}


bump_all() {
  bump_repo master  plutus                    https://www.github.com/input-output-hk/plutus                             
  bump_repo main    plutus-apps               https://www.github.com/input-output-hk/plutus-apps                        
  bump_repo main    marlowe-ts-sdk            https://www.github.com/input-output-hk/marlowe-ts-sdk                  
  bump_repo main    marlowe-agda              https://www.github.com/input-output-hk/marlowe-agda                    
  bump_repo main    marconi                   https://www.github.com/input-output-hk/marconi                         
  bump_repo master  dapps-certification       https://www.github.com/input-output-hk/dapps-certification             
  bump_repo main    marconi-sidechain-node    https://www.github.com/input-output-hk/marconi-sidechain-node          
  bump_repo main    marlowe                   https://www.github.com/input-output-hk/marlowe                         
  bump_repo main    quickcheck-dynamic        https://www.github.com/input-output-hk/quickcheck-dynamic              
  bump_repo main    marlowe-token-plans       https://www.github.com/input-output-hk/marlowe-token-plans             
  bump_repo main    marlowe-runner            https://www.github.com/input-output-hk/marlowe-runner                  
  bump_repo main    marlowe-plutus            https://www.github.com/input-output-hk/marlowe-plutus                  
  bump_repo main    marlowe-payouts           https://www.github.com/input-output-hk/marlowe-payouts                 
  bump_repo main    marlowe-cardano           https://www.github.com/input-output-hk/marlowe-cardano                 
  bump_repo main    stablecoin-plutus         https://www.github.com/input-output-hk/stablecoin-plutus               
  bump_repo master  quickcheck-contractmodel  https://www.github.com/input-output-hk/quickcheck-contractmodel        
  bump_repo main    antaeus                   https://www.github.com/input-output-hk/antaeus                         
  bump_repo main    marlowe-playground        https://www.github.com/input-output-hk/marlowe-playground              
}