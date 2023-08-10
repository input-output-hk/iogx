{ iogx, pkgs }:

let
  inherit (iogx.lib) l;


  mkTest =
    { description ? ""
    , config
    , expected ? [ ]
    , unexpected ? [ ]
    , evaluate ? null
    }:
    { inherit description config expected unexpected evaluate; };


  test-cases = {

    test_7 = mkTest {
      description = ''
        The inputs.self and inputs'.self attributes are well behaved.
      '';
      config = {
        haskell = {
          supportedCompilers = [ "ghc8107" ];
        };
        per-system-outputs = { pkgs, inputs', inputs, system, ... }: {
          # Why doesn't nix build the derivations here? FIXME 
          test = l.seq ''
            ${inputs'.self.apps.exe1.program}/bin/exe1
            ${inputs.self.${system}.apps.exe1.program}/bin/exe1
          ''
            { };
        };
      };
      evaluate = "test";
    };

    test_1 = mkTest {
      description = ''
        Can build a non-haskell flake. Produces all expected outputs.
      '';
      config = {
        formatters = {
          cabal-fmt.enable = true;
          purs-tidy.enable = true;
        };
        read-the-docs = {
          siteFolder = ".";
        };
        per-system-outputs = { pkgs, inputs', ... }: {
          per = {
            system = pkgs.hello;
          };
        };
        top-level-outputs = {
          top = {
            level = 42;
          };
        };
        ci = { };
      };
      expected = [
        "packages.pre-commit-check"
        "packages.read-the-docs-site"
        "devShells.default"
        "per.system"
        "top.level"
        "hydraJobs.packages.pre-commit-check"
        "hydraJobs.packages.read-the-docs-site"
        "hydraJobs.devShells.default"
      ];
    };

    test_2 = mkTest {
      description = ''
        Can build a haskell flake with one GHC. Produces all expected outputs.
      '';
      config = {
        formatters = {
          cabal-fmt.enable = true;
        };
        read-the-docs = {
          siteFolder = "read-the-docs";
        };
        haskell = {
          supportedCompilers = [ "ghc8107" ];
        };
      };
      expected = [
        "packages.pre-commit-check"
        "packages.read-the-docs-site"
        "devShells.default"
        "devShells.profiled"
        "apps.exe1"
        "apps.exe2"
        "apps.foo-exe-exe1"
        "apps.bar-exe-exe2"
        "packages.exe1"
        "packages.exe2"
        "packages.foo-lib-foo"
        "packages.foo-exe-exe1"
        "packages.foo-test-test1"
        "packages.foo-bench-bench1"
        "packages.bar-lib-bar"
        "packages.bar-exe-exe2"
        "packages.bar-test-test2"
        "packages.bar-bench-bench2"
        "packages.haskell-nix-project-roots"
        "packages.haskell-nix-project-plan-nix"
        "checks.foo-test-test1"
        "checks.bar-test-test2"
        "hydraJobs.packages.pre-commit-check"
        "hydraJobs.packages.read-the-docs-site"
        "hydraJobs.devShells.default"
        "hydraJobs.devShells.profiled"
        "hydraJobs.packages.exe1"
        "hydraJobs.packages.exe2"
        "hydraJobs.packages.foo-lib-foo"
        "hydraJobs.packages.foo-exe-exe1"
        "hydraJobs.packages.foo-test-test1"
        "hydraJobs.packages.foo-bench-bench1"
        "hydraJobs.packages.bar-lib-bar"
        "hydraJobs.packages.bar-exe-exe2"
        "hydraJobs.packages.bar-test-test2"
        "hydraJobs.packages.bar-bench-bench2"
        "hydraJobs.packages.haskell-nix-project-roots"
        "hydraJobs.packages.haskell-nix-project-plan-nix"
        "hydraJobs.checks.foo-test-test1"
        "hydraJobs.checks.bar-test-test2"
      ];
      unexpected = [
        "apps.exe1-ghc8107"
        "apps.exe1-ghc927"
        "apps.test1"
        "apps.bench1"
        "apps.test2"
        "apps.bench2"
      ];
    };

    test_3 = mkTest {
      description = ''
        Can build a haskell flake with two GHCs. Produces all expected outputs.
      '';
      config = {
        formatters = {
          cabal-fmt.enable = true;
        };
        read-the-docs = {
          siteFolder = "read-the-docs";
        };
        haskell = {
          supportedCompilers = [ "ghc8107" "ghc928" ];
        };
      };
      expected = [
        "packages.pre-commit-check"
        "packages.read-the-docs-site"
        "devShells.default"
        "devShells.profiled"
        "devShells.ghc8107"
        "devShells.ghc8107-profiled"
        "devShells.ghc928"
        "devShells.ghc928-profiled"
        "apps.exe1"
        "apps.exe2"
        "apps.foo-exe-exe1-ghc8107"
        "apps.foo-exe-exe1-ghc928"
        "apps.foo-test-test1-ghc8107"
        "apps.foo-test-test1-ghc928"
        "apps.bar-exe-exe2-ghc8107"
        "apps.bar-exe-exe2-ghc928"
        "apps.bar-test-test2-ghc8107"
        "apps.bar-test-test2-ghc928"
        "packages.exe1"
        "packages.exe2"
        "packages.foo-lib-foo-ghc8107"
        "packages.foo-lib-foo-ghc928"
        "packages.foo-exe-exe1-ghc8107"
        "packages.foo-exe-exe1-ghc928"
        "packages.foo-test-test1-ghc8107"
        "packages.foo-test-test1-ghc928"
        "packages.foo-bench-bench1-ghc8107"
        "packages.foo-bench-bench1-ghc928"
        "packages.bar-lib-bar-ghc8107"
        "packages.bar-lib-bar-ghc928"
        "packages.bar-exe-exe2-ghc8107"
        "packages.bar-exe-exe2-ghc928"
        "packages.bar-test-test2-ghc8107"
        "packages.bar-test-test2-ghc928"
        "packages.bar-bench-bench2-ghc8107"
        "packages.bar-bench-bench2-ghc928"
        "packages.haskell-nix-project-roots-ghc8107"
        "packages.haskell-nix-project-roots-ghc928"
        "packages.haskell-nix-project-plan-nix-ghc8107"
        "packages.haskell-nix-project-plan-nix-ghc928"
        "checks.foo-test-test1-ghc8107"
        "checks.foo-test-test1-ghc928"
        "checks.bar-test-test2-ghc8107"
        "checks.bar-test-test2-ghc928"
        "hydraJobs.packages.pre-commit-check"
        "hydraJobs.packages.read-the-docs-site"
        "hydraJobs.devShells.default"
        "hydraJobs.devShells.profiled"
        "hydraJobs.devShells.ghc8107"
        "hydraJobs.devShells.ghc8107-profiled"
        "hydraJobs.devShells.ghc928"
        "hydraJobs.devShells.ghc928-profiled"
        "hydraJobs.packages.exe1"
        "hydraJobs.packages.exe2"
        "hydraJobs.packages.foo-lib-foo-ghc8107"
        "hydraJobs.packages.foo-lib-foo-ghc8107"
        "hydraJobs.packages.foo-lib-foo-ghc928"
        "hydraJobs.packages.foo-exe-exe1-ghc8107"
        "hydraJobs.packages.foo-exe-exe1-ghc928"
        "hydraJobs.packages.foo-test-test1-ghc8107"
        "hydraJobs.packages.foo-test-test1-ghc928"
        "hydraJobs.packages.foo-bench-bench1-ghc8107"
        "hydraJobs.packages.foo-bench-bench1-ghc928"
        "hydraJobs.packages.bar-lib-bar-ghc8107"
        "hydraJobs.packages.bar-lib-bar-ghc928"
        "hydraJobs.packages.bar-exe-exe2-ghc8107"
        "hydraJobs.packages.bar-exe-exe2-ghc928"
        "hydraJobs.packages.bar-test-test2-ghc8107"
        "hydraJobs.packages.bar-test-test2-ghc928"
        "hydraJobs.packages.bar-bench-bench2-ghc8107"
        "hydraJobs.packages.bar-bench-bench2-ghc928"
        "hydraJobs.packages.haskell-nix-project-roots-ghc8107"
        "hydraJobs.packages.haskell-nix-project-roots-ghc928"
        "hydraJobs.packages.haskell-nix-project-plan-nix-ghc8107"
        "hydraJobs.packages.haskell-nix-project-plan-nix-ghc928"
        "hydraJobs.checks.foo-test-test1-ghc8107"
        "hydraJobs.checks.foo-test-test1-ghc928"
        "hydraJobs.checks.bar-test-test2-ghc8107"
        "hydraJobs.checks.bar-test-test2-ghc928"
      ];
      unexpected = [
        "apps.exe1-ghc8107"
        "apps.exe1-ghc928"
        "apps.test1-ghc8107"
        "apps.test1-ghc928"
        "apps.bench1-ghc8107"
        "apps.bench1-ghc928"
        "apps.exe2-ghc8107"
        "apps.exe2-ghc928"
        "apps.test2-ghc8107"
        "apps.test2-ghc928"
        "apps.bench2-ghc8107"
        "apps.bench2-ghc928"
        "packages.exe1-ghc8107"
        "packages.exe1-ghc928"
        "packages.test1-ghc8107"
        "packages.test1-ghc928"
        "packages.bench1-ghc8107"
        "packages.bench1-ghc928"
        "packages.exe2-ghc8107"
        "packages.exe2-ghc928"
        "packages.test2-ghc8107"
        "packages.test2-ghc928"
        "packages.bench2-ghc8107"
        "packages.bench2-ghc928"
      ];
    };

    test_4 = mkTest {
      description = ''
        ci.includedPaths includes extra per-system-outputs paths in hydraJobs.
      '';
      config = {
        per-system-outputs = { pkgs, ... }: {
          per = {
            system = pkgs.hello;
          };
        };
        ci = {
          includedPaths = [
            "per.system"
          ];
        };
      };
      expected = [
        "hydraJobs.per.system"
      ];
    };

    test_5 = mkTest {
      description = ''
        ci.excludedPaths excludes the desired paths from hydraJobs.
      '';
      config = {
        per-system-outputs = { pkgs, ... }: {
          packages.bar.include = pkgs.hello;
          packages.bar.exclude = pkgs.hello;
          foo = {
            include = pkgs.hello;
            exclude = pkgs.hello;
          };
        };
        ci = {
          includedPaths = [
            "foo"
            "packages.bar.include"
          ];
          excludedPaths = [
            "foo.exclude"
            "packages.bar.exclude"
          ];
        };
      };
      expected = [
        "hydraJobs.packages.bar.include"
        "hydraJobs.foo.include"
      ];
      unexpected = [
        "hydraJobs.packages.bar.exclude"
        "hydraJobs.foo.exclude"
      ];
    };

    test_6 = mkTest {
      description = ''
        The nix module folder works.
      '';
      config = {
        per-system-outputs = { nix, ... }: {
          packages.hello-world = nix.hello.world;
        };
      };
      expected = [
        "packages.hello-world"
      ];
    };

    test_8 = mkTest {
      description = ''
        Test that ci.nix:includeDefaultOutputs behaves.
      '';
      config = {
        haskell = {
          supportedCompilers = [ "ghc8107" ];
        };
        ci = {
          includeDefaultOutputs = false;
        };
        read-the-docs = {
          siteFolder = "read-the-docs";
        };
      };
      expected = [
        "packages.read-the-docs-site"
        "packages.pre-commit-check"
      ];
      unexpected = [
        "hydraJobs.packages.read-the-docs-site"
        "hydraJobs.packages.pre-commit-check"
        "hydraJobs.apps.exe1"
      ];
    };
  };


  runTest = test-name: test:
    let
      system = pkgs.stdenv.system;

      flake = iogx.lib.mkFlake {
        inputs = {
          self = {
            "${system}" = { };
            outputPath = ./repo;
          };
        };
        repoRoot = ./repo;
        systems = [ system ];
        config = test.config;
        debug = true;
      };

      flake' = l.deSystemize system flake;

      flake'' = iogx.lib.mkFlake {
        inputs = {
          self = {
            "${system}" = flake';
            outputPath = ./repo;
          };
        };
        repoRoot = ./repo;
        systems = [ system ];
        config = test.config;
        debug = true;
      };

      # Alas, in test code, the magical inputs.self isn't populated with 
      # the final outputs (contrary to what would happen in a "real" flake).
      # So if we want to test hydraJobs specifically (which uses `inputs.self`)
      # We have to call iogx.lib.mkFlake and "mock" the `self` attribute twice. 
      flake''' = l.deSystemize system flake'';

      expected-outputs-checks = map
        (path:
          if l.hasAttrByPathString path flake''' then
            l.seq (l.getAttrByPathString path flake''') true
          else
            l.pthrow ''
              ------ ${test-name}
              Expected output not found: ${path}
            ''
        )
        test.expected;

      unexpected-outputs-checks = map
        (path:
          if !(l.hasAttrByPathString path flake''') then
            true
          else
            l.pthrow ''
              ------ ${test-name}
              Unexpected output found: ${path}
            ''
        )
        test.unexpected;

      evaluate-check =
        let x = l.getAttrByPathString test.evaluate flake''';
        in if test.evaluate == null then true else l.seq x true;

      check-results =
        expected-outputs-checks ++ unexpected-outputs-checks ++ [ evaluate-check ];

    in
    check-results;


  testsuite = l.mapAttrs runTest test-cases;


  evaluated-testsuite = l.deepSeq testsuite "success";

in

evaluated-testsuite

