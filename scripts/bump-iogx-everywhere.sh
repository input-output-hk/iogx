#!/usr/bin/env bash

set -e 

create_draft_pr="no"
custom_iogx_branch="custom-precommit-hooks"
vbump_tag="2024-01-17"


iogx_vbump_repo() {
  local repo_branch="$1"
  local repo_folder="$2"
  local add_no_changelog_required_label="$3"

  cd "../$repo_folder" || return
  git stash
  git checkout "$repo_branch"
  find . -name "*.DS_Store" -delete
  git pull
  git checkout -b "iogx-bump-$vbump_tag" || git checkout "iogx-bump-$vbump_tag"
  git pull --rebase origin "$repo_branch"
  if [ "$custom_iogx_branch" != "" ]; then
    sed -i '' "'s|github:input-output-hk/iogx|github:input-output-hk/iogx?ref=$custom_iogx_branch|'" flake.nix
  fi
  nix flake lock --update-input iogx
  git add .
  git commit -m "Bump IOGX $vbump_tag" --no-verify
  git push
  if [ "$create_draft_pr" == "yes" ]; then
    if [ "$add_no_changelog_required_label" == "yes" ]; then
      gh pr create --title "Bump IOGX $vbump_tag" --body "Automated version bump" --draft --label "No Changelog Required"
    else
      gh pr create --title "Bump IOGX $vbump_tag" --body "Automated version bump" --draft 
    fi
  fi
}


iogx_vbump_plutus() { iogx_vbump_repo master plutus yes; }
iogx_vbump_plutus_apps() { iogx_vbump_repo main plutus-apps yes; }
iogx_vbump_marlowe_ts_sdk() { iogx_vbump_repo main marlowe-ts-sdk no; }
iogx_vbump_marlowe_agda() { iogx_vbump_repo main marlowe-agda no; }
iogx_vbump_marconi() { iogx_vbump_repo main marconi no; }
iogx_vbump_dapps_certification() { iogx_vbump_repo master dapps-certification no; }
iogx_vbump_marconi_sidechain_node() { iogx_vbump_repo main marconi-sidechain-node no; }
iogx_vbump_marlowe() { iogx_vbump_repo main marlowe no; }
iogx_vbump_quickcheck_dynamic() { iogx_vbump_repo main quickcheck-dynamic no; }
iogx_vbump_marlowe_token_plans() { iogx_vbump_repo main marlowe-token-plans no; }
iogx_vbump_marlowe_runner() { iogx_vbump_repo main marlowe-runner no; }
iogx_vbump_marlowe_plutus() { iogx_vbump_repo main marlowe-plutus no; }
iogx_vbump_marlowe_payouts() { iogx_vbump_repo main marlowe-payouts no; }
iogx_vbump_marlowe_cardano() { iogx_vbump_repo main marlowe-cardano no; }
iogx_vbump_stablecoin_plutus() { iogx_vbump_repo main stablecoin-plutus no; }
iogx_vbump_quickcheck_contractmodel() { iogx_vbump_repo master quickcheck-contractmodel no; }
iogx_vbump_antaeus() { iogx_vbump_repo main antaeus no; }
iogx_vbump_marlowe_playground() { iogx_vbump_repo main marlowe-playground no; }


iogx_vbump_everywhere() {
  iogx_vbump_plutus                    
  iogx_vbump_plutus_apps               
  iogx_vbump_marlowe_ts_sdk            
  iogx_vbump_marlowe_agda              
  iogx_vbump_marconi                   
  iogx_vbump_dapps_certification       
  iogx_vbump_marconi_sidechain_node    
  iogx_vbump_marlowe                   
  iogx_vbump_quickcheck_dynamic        
  iogx_vbump_marlowe_token_plans       
  iogx_vbump_marlowe_runner            
  iogx_vbump_marlowe_plutus            
  iogx_vbump_marlowe_payouts           
  iogx_vbump_marlowe_cardano           
  iogx_vbump_stablecoin_plutus         
  iogx_vbump_quickcheck_contractmodel  
  iogx_vbump_antaeus                   
  iogx_vbump_marlowe_playground        
}


iogx_vbump_$1