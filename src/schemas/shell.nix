{ libnixschema }:

let

  V = libnixschema.validators;


  scripts-schema = {
    enable.type = V.bool;
    enable.default = true;

    group.type = V.nonempty-string;
    group.default = "unknown";

    exec.type = V.any;
    # Some scripts only run on some systems.
    # So the `exec` field may fail to evaluate in nix on unsupported systems.
    # However, validiting a config forces evaluation of all its fields.
    # Therefore, we can't validate exec (V.any always succeeds and doesn't force evaluation).
    # FIXME can this be worked around somehow? 
    
    description.type = V.string;
    description.default = "";
  };
  

  schema = {
    name.type = V.nonempty-string;
    name.default = "nix-shell";

    prompt.type = V.nonempty-string;
    prompt.default = conf: "\n\\[\\033[1;32m\\][${conf.name}:\\w]\\$\\[\\033[0m\\] ";

    welcomeMessage.type = V.nonempty-string;
    welcomeMessage.default = conf: "🤟 \\033[1;31mWelcome to ${conf.name}\\033[0m 🤟";

    packages.type = V.list; # FIXME V.list-of V.drv segfaults
    packages.default = [];

    scripts.type = V.attrset-of (V.schema scripts-schema);
    scripts.default = {}; 

    env.type = V.attrset-of V.string;
    env.default = {};

    enterShell.type = V.string;
    enterShell.default = "";
  };

in

  schema