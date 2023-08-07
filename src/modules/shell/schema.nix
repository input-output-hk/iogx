validators: with validators;

let

  scripts-schema = {

    enable.type = bool;
    enable.default = true;

    group.type = nonempty-string;
    group.default = "unknown";

    exec.type = any;
    # Some scripts only run on some systems.
    # So the `exec` field may fail to evaluate in nix on unsupported systems.
    # However, validiting a config forces evaluation of all its fields.
    # Therefore, we can't validate exec (any always succeeds and doesn't force evaluation).
    # FIXME can this be worked around somehow? 

    description.type = string;
    description.default = "";
  };

in

{
  name.type = nonempty-string;
  name.default = "nix-shell";

  prompt.type = nonempty-string;
  prompt.default = conf: "\n\\[\\033[1;32m\\][${conf.name}:\\w]\\$\\[\\033[0m\\] ";

  welcomeMessage.type = nonempty-string;
  welcomeMessage.default = conf: "🤟 \\033[1;31mWelcome to ${conf.name}\\033[0m 🤟";

  packages.type = list; # FIXME list-of drv segfaults
  packages.default = [ ];

  scripts.type = attrset-of (schema scripts-schema);
  scripts.default = { };

  env.type = attrset-of string;
  env.default = { };

  enterShell.type = string;
  enterShell.default = "";
}
