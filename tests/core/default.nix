{ iogx, pkgs }:

let
  inherit (iogx.lib) l;

  test-cases = {

    test_1 = {
      description = ''
        Can build a non-haskell flake. Produces all expected outputs.
      '';
      config = {
        formatters = {
          cabal-fmt.enable = true;
        };
        read-the-docs = {
          siteFolder = ".";
        };
        per-system-outputs = {
          per = {
            system = 42;
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
        # "hydraJobs.packages.pre-commit-check"
        # "hydraJobs.packages.read-the-docs-site"
        # "hydraJobs.devShells.default"
      ];
      unexpected = [ ];
    };

    test_2 = {
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
        "packages.pre-commit-check-ghc8107"
        "packages.read-the-docs-site"
        "devShells.default"
        "devShells.profiled"
        "packages.foo-lib-foo"
        "packages.foo-lib-foo-profiled"
        "packages.exe"
        "packages.test"
        "packages.bench"
        "packages.foo-exe-exe"
        "packages.foo-exe-exe-profiled"
        "packages.foo-test-test"
        "packages.foo-test-test-profiled"
        "packages.foo-bench-bench"
        "packages.foo-bench-bench-profiled"
        "packages.bar-lib-bar"
        "packages.bar-lib-bar-profiled"
        "packages.bar-exe-exe"
        "packages.bar-exe-exe-profiled"
        "packages.bar-test-test"
        "packages.bar-test-test-profiled"
        "packages.bar-bench-bench"
        "packages.bar-bench-bench-profiled"
        "packages.haskell-nix-project-roots"
        "packages.haskell-nix-project-roots-profiled"
        "packages.haskell-nix-project-plan-nix"
        "packages.haskell-nix-project-plan-nix-profiled"
      ];
      unexpected = [ ];
    };

    test_3 = {
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
        "packages.pre-commit-check-ghc8107"
        "packages.pre-commit-check-ghc928"
        "packages.read-the-docs-site"
        "devShells.default"
        "devShells.profiled"
        "devShells.ghc8107"
        "devShells.ghc8107-profiled"
        "devShells.ghc928"
        "devShells.ghc928-profiled"
        "packages.foo-lib-foo-ghc8107"
        "packages.foo-lib-foo-ghc8107-profiled"
        "packages.foo-lib-foo-ghc928"
        "packages.foo-lib-foo-ghc928-profiled"
        "packages.foo-exe-exe-ghc8107"
        "packages.foo-exe-exe-ghc8107-profiled"
        "packages.foo-exe-exe-ghc928"
        "packages.foo-exe-exe-ghc928-profiled"
        "packages.foo-test-test-ghc8107"
        "packages.foo-test-test-ghc8107-profiled"
        "packages.foo-test-test-ghc928"
        "packages.foo-test-test-ghc928-profiled"
        "packages.foo-bench-bench-ghc8107"
        "packages.foo-bench-bench-ghc8107-profiled"
        "packages.foo-bench-bench-ghc928"
        "packages.foo-bench-bench-ghc928-profiled"
        "packages.bar-lib-bar-ghc8107"
        "packages.bar-lib-bar-ghc8107-profiled"
        "packages.bar-lib-bar-ghc928"
        "packages.bar-lib-bar-ghc928-profiled"
        "packages.bar-exe-exe-ghc8107"
        "packages.bar-exe-exe-ghc8107-profiled"
        "packages.bar-exe-exe-ghc928"
        "packages.bar-exe-exe-ghc928-profiled"
        "packages.bar-test-test-ghc8107"
        "packages.bar-test-test-ghc8107-profiled"
        "packages.bar-test-test-ghc928"
        "packages.bar-test-test-ghc928-profiled"
        "packages.bar-bench-bench-ghc8107"
        "packages.bar-bench-bench-ghc8107-profiled"
        "packages.bar-bench-bench-ghc928"
        "packages.bar-bench-bench-ghc928-profiled"
        "packages.haskell-nix-project-roots-ghc8107"
        "packages.haskell-nix-project-roots-ghc8107-profiled"
        "packages.haskell-nix-project-roots-ghc928"
        "packages.haskell-nix-project-roots-ghc928-profiled"
        "packages.haskell-nix-project-plan-nix-ghc8107"
        "packages.haskell-nix-project-plan-nix-ghc8107-profiled"
        "packages.haskell-nix-project-plan-nix-ghc928"
        "packages.haskell-nix-project-plan-nix-ghc928-profiled"
      ];
      unexpected = [ ];
    };

    test_4 = {
      description = ''
        ci.includedPaths includes extra per-system-outputs paths in hydraJobs.
      '';
      config = {
        per-system-outputs = {
          per = {
            system = { };
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
      unexpected = [ ];
    };

    test_5 = {
      description = ''
        ci.excludedPaths excludes the desired paths from hydraJobs.
      '';
      config = {
        per-system-outputs = {
          packages.bar.include = { };
          packages.bar.exclude = { };
          foo = {
            include = { };
            exclude = { };
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
        # "hydraJobs.packages.bar.exclude"
        # "hydraJobs.foo.exclude" 
      ];
    };
  };


  runTest = name: test:
    let
      flake = iogx.lib.mkFlake {
        inputs = {
          self = {
            "${pkgs.stdenv.system}" = { };
            outputPath = ./repo;
          };
        };
        repoRoot = ./repo;
        systems = [ pkgs.stdenv.system ];
        config = test.config;
      };

      flake' = l.deSystemize pkgs.stdenv.system flake;

      flake'' = iogx.lib.mkFlake {
        inputs = {
          self = {
            "${pkgs.stdenv.system}" = flake';
            outputPath = ./repo;
          };
        };
        repoRoot = ./repo;
        systems = [ pkgs.stdenv.system ];
        config = test.config;
      };

      flake''' = flake'; #l.deSystemize pkgs.stdenv.system flake'';

      expected-outputs-checks = map
        (path:
          if l.hasAttrByPathString path flake''' then
            true
          else
            l.pthrow ''
              ------ ${name}
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
              ------ ${name}
              Unexpected output found: ${path}
            ''
        )
        test.unexpected;

      check-results = expected-outputs-checks ++ unexpected-outputs-checks;
    in
    check-results;


  testsuite = l.mapAttrs runTest test-cases;


  evaluated-testsuite = l.deepSeq testsuite "success";

in

evaluated-testsuite

