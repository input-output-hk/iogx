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
    # Therefore we make this field "lazy" and only evaluate it if `enable` is true.
    # FIXME this is any because it depends on enable and may fail to evaluate on some systems

    description.type = V.string;
    description.default = "";
  };
  

  schema = {
    name.type = V.nonempty-string;
    name.default = "devShell";

    prompt.type = V.nonempty-string;
    prompt.default = conf: "\n\\[\\033[1;32m\\][${conf.name}:\\w]\\$\\[\\033[0m\\] ";

    welcomeMessage.type = V.nonempty-string;
    welcomeMessage.default = conf: "🤟 \\033[1;31mWelcome to ${conf.name}\\033[0m 🤟";

    packages.type = V.list; # TODO V.list-of V.drv segfaults
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