{ l, ... }:

let

  mergeTwoShellProfiles = p1: p2:
    {
      packages =
        l.getAttrWithDefault "packages" [ ] p1 ++
        l.getAttrWithDefault "packages" [ ] p2;

      scripts =
        let
          scripts1 = l.getAttrWithDefault "scripts" { } p1;
          scripts2 = l.getAttrWithDefault "scripts" { } p2;
        in
        # TODO check clashes
        scripts1 // scripts2;

      env =
        let
          env1 = l.getAttrWithDefault "env" { } p1;
          env2 = l.getAttrWithDefault "env" { } p2;
        in
        # TODO check clashes
        env1 // env2;

      enterShell =
        l.concatStringsSep "\n" [
          (l.getAttrWithDefault "enterShell" "" p1)
          (l.getAttrWithDefault "enterShell" "" p2)
        ];
    };


  makeMergedShellProfile = l.foldl' mergeTwoShellProfiles { };

in

makeMergedShellProfile
