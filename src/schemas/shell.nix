{ libnixschema, l }:

let

  V = libnixschema.validators;


  scripts-schema = {
    enable.type = V.bool;
    enable.default = true;

    group.type = V.nonempty-string;
    group.default = "unknown";

    exec.type = V.nonempty-string;

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

    packages.type = V.list-of V.drv;
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