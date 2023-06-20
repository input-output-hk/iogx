{ missingField, invalidField, defaultField, successField, iogx-schemas }:

let 

  config = {};
  

  schema = iogx-schemas.shell;


  testsuite = [
    (invalidField config schema "name" "type-mismatch" 1)
    (invalidField config schema "name" "empty-string" "")
    (defaultField config schema "name" "devShell")
    (successField config schema "name" "devShell")
    (successField config schema "name" "myshell")

    (invalidField config schema "prompt" "type-mismatch" 1)
    (invalidField config schema "prompt" "empty-string" "")
    (defaultField config schema "prompt" "\n\\[\\033[1;32m\\][devShell:\\w]\\$\\[\\033[0m\\] ")
    (successField config schema "prompt" "prompt")

    (invalidField config schema "welcomeMessage" "type-mismatch" 1)
    (invalidField config schema "welcomeMessage" "empty-string" "")
    (defaultField config schema "welcomeMessage" "🤟 \\033[1;31mWelcome to devShell\\033[0m 🤟")
    (successField config schema "welcomeMessage" "welcomeMessage")

    (invalidField config schema "packages" "type-mismatch" 1)
    (invalidField config schema "packages" "invalid-list-elem" [1])
    (defaultField config schema "packages" []) 

    (invalidField config schema "env" "type-mismatch" 1)
    (invalidField config schema "env" "invalid-attr-elem" { A = 1; })
    (defaultField config schema "env" {})
    (successField config schema "env" {})
    (successField config schema "env" { A = "B"; })

    (invalidField config schema "enterShell" "type-mismatch" 1)
    (defaultField config schema "enterShell" "")
    (successField config schema "enterShell" "")
    (successField config schema "enterShell" "hello")

    (invalidField config schema "scripts" "type-mismatch" 1)
    (invalidField config schema "scripts" "type-mismatch" 1)

    (invalidField config schema "scripts" "invalid-attr-elem" { s = { enable = 1; a = 2;}; })
    (invalidField config schema "scripts" "invalid-attr-elem" { s = { enable = true; exec = ""; }; })
    (invalidField config schema "scripts" "invalid-attr-elem" { s = { enable = true; exec = "a"; group = ""; }; })
    (invalidField config schema "scripts" "invalid-attr-elem" { s = { enable = true; exec = "a"; group = "a"; a = 1;}; })
    (defaultField config schema "scripts" {})
    (successField config schema "scripts" {})
    (successField config schema "scripts" { s = { enable = true; exec = "a"; group = "a"; }; })
  
    (invalidField config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite