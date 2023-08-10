import os 


repo_folder_names = [
  "antaeus",
  "marlowe-cardano",
  "marconi",
  "quickcheck-dynamic",
  "quickcheck-contractmodel",
  "stablecoin-plutus",
  "dapps-certification",
  "plutus",
  "plutus-apps",
  "marlowe-playground"
]


template_file_names = [
  "flake.nix",
  "nix/cabal-project.nix",
  "nix/ci.nix",
  "nix/formatters.nix",
  "nix/haskell.nix",
  "nix/per-system-outputs.nix",
  "nix/read-the-docs.nix",
  "nix/shell.nix",
  "nix/top-level-outputs.nix"
]


def extract_comment_lines_from_template_files():
  out = {}
  for name in template_file_names:
    with open(f"./template/{name}") as file:
      lines = file.readlines()
      out[name] = [lines[0], lines[1]]
  return out 


COMMENT_LINES_DICT = extract_comment_lines_from_template_files()


def insert_template_comments_in_file(template, path):
  buff = []
  if not os.path.exists(path):
    return 
  with open(path, 'r') as file:
    lines = file.readlines()
    if len(lines) < 1: 
      print(f"The file {path} is empty")
      return 
    if lines[0].startswith("# This file is part of"):
      if lines[1].startswith("# https://www.github.com"):
        buff.append(COMMENT_LINES_DICT[template][0])
        buff.append(COMMENT_LINES_DICT[template][1])
        buff = buff + lines[2:]
    elif lines[0] == "" or lines[0].startswith("{"):
        buff.append(COMMENT_LINES_DICT[template][0])
        buff.append(COMMENT_LINES_DICT[template][1])
        buff.append("\n")
        buff = buff + lines
    else:
      print(f"The file {path} is weird")
      return 
  with open(path, 'w') as file:
    file.writelines("".join(buff)) 


def insert_template_comments_in_repos():
  for repo in repo_folder_names:
    for template in template_file_names:
      insert_template_comments_in_file(template, f"../{repo}/{template}")


insert_template_comments_in_repos()