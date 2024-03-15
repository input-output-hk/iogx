# `jira-cli` Installation, Usage & Cheatsheet

1. Download the `jira-cli` [binary](https://github.com/ankitpokhrel/jira-cli/releases) or with nix:
  - `nix profile install nixpkgs#jira-cli-go`

2. Install `jira-cli` following the official [instructions](https://github.com/ankitpokhrel/jira-cli#getting-started) or just do this:
  - Generate and copy a `JIRA_API_TOKEN` from [this page](https://id.atlassian.com/manage-profile/security/api-tokens)
  - `export` the token in your terminal and `~/.bash_rc` or `~/.zshrc`
  - Test installation with: `jira version`

3. Run `jira init` in your terminal, referring to the data below:
  ```bash
  jira init
  ? Installation type: Cloud
  ? Link to Jira server: https://input-output.atlassian.net
  ? Login email: <your-email>@iohk.io
  ? Default project: PLT
  ? Default board: SC Shared Services
  ```

- Test configuration: `jira issues list -a$(jira me) -s"Backlog"`

# Useful Commands 

- List everything in your backlog 
  ```
  jira issues list -a$(jira me) -s"Backlog"
  ```

- List the stories in your backlog 
  ```
  jira issues list -a$(jira me) -s"Backlog" -t"Story"
  ```

# Create a PI Objective

Copy-paste the snippet below to a file, modify the variables as needed and run the whole thing in your terminal.

```bash
SUMMARY="jira-cli-created test PI objective (delete me)"
read -r -d '' BODY <<'EOF'

# Markdown Available 

- Item 1 

- Item 2
EOF
jira issue create \
  --type="PI Objective" \
  --summary="$SUMMARY" \
  --body="$BODY" \
  --custom squad="SHARED SERVICES" \
  --no-input \
  --web
```

# Create a Story

Copy-paste the snippet below to a file, modify the variables as needed and run the whole thing in your terminal.

```bash 
TYPE="Story" 
ASSIGNEE="$(jira me)"
PARENT_EPIC="PLT-0000"
PRIORITY="Medium"
SUMMARY="jira-cli-created test story (delete me)"
read -r -d '' BODY <<'EOF'

# Markdown Available 

- Item 1 

- Item 2
EOF
jira issue create \
  --type="$TYPE" \
  --assignee="$ASSIGNEE" \
  --summary="$SUMMARY" \
  --parent="$PARENT_EPIC" \
  --priority="$PRIORITY" \
  --custom squad="SHARED SERVICES" \
  --body="$BODY" \
  --web \
  --no-input
```

# Create an Epic

This doesn't work because `jira-cli` does not have a `--parent` flag...

But if it did work, this is what it would look like.

Copy-paste the snippet below to a file, modify the variables as needed and run the whole thing in your terminal.

```bash
ASSIGNEE="$(jira me)"
PRIORITY="Medium"
NAME="..."
SUMMARY="..."
PARENT_PI_OBJECTIVE="PLT-0000" 
read -r -d '' BODY <<'EOF'

# Markdown Available 

- Item 1 

- Item 2
EOF
jira epic create \
  --name="$NAME" \
  --summary="$SUMMARY" \
  --custom squad="SHARED SERVICES" \
  --assignee="$ASSIGNEE" \
  --parent="$PARENT_PI_OBJECTIVE" \
  --body="$BODY" \
  --web \
  --no-input 
```