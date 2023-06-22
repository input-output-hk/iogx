{ missingField, invalidField, defaultField, successField }:

schema:

let 

  config = {};
  

  testsuite = [
    (invalidField "shell-01" config schema "name" "type-mismatch" 1)
    (invalidField "shell-02" config schema "name" "empty-string" "")
    (defaultField "shell-03" config schema "name" "devShell")
    (successField "shell-04" config schema "name" "devShell")
    (successField "shell-05" config schema "name" "myshell")

    (invalidField "shell-06" config schema "prompt" "type-mismatch" 1)
    (invalidField "shell-07" config schema "prompt" "empty-string" "")
    (defaultField "shell-08" config schema "prompt" "\n\\[\\033[1;32m\\][devShell:\\w]\\$\\[\\033[0m\\] ")
    (successField "shell-09" config schema "prompt" "prompt")

    (invalidField "shell-10" config schema "welcomeMessage" "type-mismatch" 1)
    (invalidField "shell-11" config schema "welcomeMessage" "empty-string" "")
    (defaultField "shell-12" config schema "welcomeMessage" "🤟 \\033[1;31mWelcome to devShell\\033[0m 🤟")
    (successField "shell-13" config schema "welcomeMessage" "welcomeMessage")

    (invalidField "shell-14" config schema "packages" "type-mismatch" 1)
    (defaultField "shell-16" config schema "packages" []) 

    (invalidField "shell-17" config schema "env" "type-mismatch" 1)
    (invalidField "shell-18" config schema "env" "invalid-attr-elem" { A = 1; })
    (defaultField "shell-19" config schema "env" {})
    (successField "shell-20" config schema "env" {})
    (successField "shell-21" config schema "env" { A = "B"; })

    (invalidField "shell-22" config schema "enterShell" "type-mismatch" 1)
    (defaultField "shell-23" config schema "enterShell" "")
    (successField "shell-24" config schema "enterShell" "")
    (successField "shell-25" config schema "enterShell" "hello")

    (invalidField "shell-26" config schema "scripts" "type-mismatch" 1)
    (invalidField "shell-27" config schema "scripts" "type-mismatch" 1)
    (invalidField "shell-28" config schema "scripts" "invalid-attr-elem" { s = { enable = 1; a = 2;}; })
    (invalidField "shell-30" config schema "scripts" "invalid-attr-elem" { s = { enable = true; exec = "a"; group = ""; }; })
    (invalidField "shell-31" config schema "scripts" "invalid-attr-elem" { s = { enable = true; exec = "a"; group = "a"; a = 1;}; })
    (defaultField "shell-32" config schema "scripts" {})
    (successField "shell-33" config schema "scripts" {})
    (successField "shell-34" config schema "scripts" { s = { enable = true; exec = "a"; group = "a"; }; })

    (invalidField "shell-35" config schema "__unknown" "unknown-field" 1)
  ];

in 

  testsuite