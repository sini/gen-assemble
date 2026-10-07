{
  inputs = {
    gen-harness.url = "github:sini/gen-harness";
    # nixpkgs is the CI runner's dependency (nix-unit harness, treefmt) and supplies the `lib` the
    # test modules use — including, here, to run the purity scan itself. It enters ONLY in ci/,
    # never as a `lib/` dep: the library (../lib) is nixpkgs-lib-free, which ci/tests/purity.nix
    # enforces. gen-assemble itself takes no inputs, so gen-harness and nixpkgs are the whole pin
    # set; every other runner input resolves through the harness's own pins.
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    # THE SUBSTRATE, AND A SECOND PIN OF IT THAT DOES NOT MEET THE PRECONDITIONS.
    #
    # The library takes its substrate injected, so the library itself declares no dependency on it —
    # but the ACCEPTANCE RUN must supply one, and `gen-scope` is it. `gen-scope-unmet` is pinned one
    # commit before the declared vertex order landed, which is what arms the precondition refusal:
    # without a pin where a precondition genuinely fails, that oracle passes vacuously and a
    # consumer learns nothing from it being green.
    gen-scope.url = "github:sini/gen-scope";
    gen-scope.inputs.gen-prelude.follows = "gen-prelude";
    gen-scope.inputs.gen-graph.inputs.gen-prelude.follows = "gen-prelude";
    gen-scope-unmet.url = "github:sini/gen-scope/ff5fe420a2869ae13d0096e2604579c88f23da7a";

    # THE ALGEBRA AND THE PRELUDE ARE PINNED HERE. `gen-scope` no longer declares `gen-schema`, so
    # `gen-scope>gen-schema>gen-algebra` — the route this file used to reach the algebra through —
    # is a dead path, not a longer one. The library takes an algebra either way, so this run declares
    # it directly, the same edge the root flake declares. The prelude is declared and the substrate
    # (with its gen-graph) FOLLOWS it, so the run still wires one prelude, the one the substrate
    # resolves; it is declared because the refusal cells compose their expected text through its
    # `refusals` (den-hoag-7jltk), and that is the copy the library throws from.
    gen-algebra.url = "github:sini/gen-algebra";
    gen-prelude.url = "github:sini/gen-prelude";
  };

  outputs =
    inputs@{
      gen-harness,
      gen-algebra,
      gen-prelude,
      gen-scope,
      gen-scope-unmet,
      ...
    }:
    let
      scope = gen-scope.lib;
      prelude = gen-prelude.lib;
      algebra = gen-algebra.lib;
      genAssemble = import ../lib { inherit prelude scope algebra; };
      # The same library over a substrate that does not meet the preconditions. Nothing is forced
      # here; the suite forces it, which is where the refusal is asserted.
      genAssembleUnmet = import ../lib {
        inherit prelude algebra;
        scope = gen-scope-unmet.lib;
      };
    in
    gen-harness.lib.mkCi {
      inherit inputs;
      name = "gen-assemble";
      testModules = ./tests;
      specialArgs = {
        inherit
          genAssemble
          genAssembleUnmet
          scope
          prelude
          algebra
          ;
      };
      # Cells whose subject is an error MESSAGE cannot live under `testModules`: the batch asserter
      # behind `checks.default` quantifies over `flake.tests` and forces every `expr`
      # unconditionally, so a cell with no `expected` and a throwing `expr` CRASHES that gate
      # instead of failing it. They get their own output, read by
      # `nix-unit --flake ./ci#testsError`, and being outside ./tests is what keeps that split
      # structural rather than conventional.
      extraModules = [
        ./tests-error.nix
      ];
    };
}
