# THE DOOR CHECKS (den-hoag-7gp66 P2 — `prelude.door`, R7 argument structure / R5 field closure) —
# every published door catches its own violations, at its own application, catchably.
#
# `assemble { kinds?; strategies?; strict?; } contributions` and `union { strategies?; }
# contributions`: the defaulted fields are one closed options set, first in the call (rule 2), and
# the contributions are the subject, positional and last (rule 4). An unknown option is refused at
# `f opts`'s WHNF, before any contribution (G1/G4); the contract is published as data (D3); a
# non-default option reaches the result and agrees with the full call (G3). No record step remains,
# so no door carries `optionsStep` and the "extra field admitted" member (R5's price) has no row.
#
# WHICH refusal fired is a claim about the message and `tryEval` yields only `success`; the byte
# goldens naming each door (R6) live in `ci/tests-error.nix`'s `flake.testsError`.
{
  genAssemble,
  prelude,
  ...
}:
let
  # WHNF only (`seq`, never `deepSeq`): the check is forced by the options application itself.
  refusesCatchably = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
  firesAtApplication = e: !(builtins.tryEval (builtins.seq e null)).success;
  answers = e: (builtins.tryEval (builtins.deepSeq e null)).success;

  # Two layers declaring one list field on one node: `append` concatenates them, the default
  # `replace` keeps the last.
  layers = [
    {
      name = "p";
      vertices = [ "a" ];
      decls.a.v = [ 1 ];
    }
    {
      name = "q";
      vertices = [ "a" ];
      decls.a.v = [ 2 ];
    }
  ];
  appended = {
    strategies.v = "append";
  };

  rows = {
    assemble = {
      optional = [
        "kinds"
        "strategies"
        "strict"
      ];
      observe = r: r.nodes.a.decls.v;
    };
    union = {
      optional = [ "strategies" ];
      observe = r: r.decls.a.v;
    };
  };
  perRow = f: builtins.mapAttrs f rows;
  stranger = "not-a-field-of-" + builtins.concatStringsSep "-" (builtins.attrNames rows);
in
{
  flake.tests.doorChecks = {
    # ★ LIVE CONTROL FOR THE WHOLE SUITE, first: `tryEval` catches an ORDINARY throw, and a
    # non-throwing value answers. Without this, every `refusesCatchably` cell below is equally
    # consistent with a broken helper that reads `false` no matter what it is handed.
    test-control-tryeval-catches-an-ordinary-throw = {
      expr = refusesCatchably (throw "control probe, not this suite's subject");
      expected = true;
    };
    test-control-tryeval-answers-a-non-throwing-value = {
      expr = answers 1;
      expected = true;
    };

    test-control-firesAtApplication-is-false-for-a-throw-behind-an-unread-field = {
      expr = firesAtApplication { culprit = throw "control probe, not this suite's subject"; };
      expected = false;
    };
    test-control-firesAtApplication-is-true-for-an-ordinary-throw = {
      expr = firesAtApplication (throw "control probe, not this suite's subject");
      expected = true;
    };

    # ── THE TABLE IS THE SURFACE ──
    test-the-door-table-equals-the-surface-doors = {
      expr = builtins.attrNames (
        prelude.filterAttrs (_: v: builtins.isAttrs v && v ? __functor && v ? __contract) genAssemble
      );
      expected = builtins.attrNames rows;
    };

    # G1/G4: an unknown option, and a non-set, are refused at the options application.
    test-an-unknown-option-is-refused-at-the-options-application = {
      expr = perRow (n: _: firesAtApplication (genAssemble.${n} { ${stranger} = 1; }));
      expected = perRow (_: _: true);
    };
    test-a-non-set-options-argument-is-refused-at-the-application = {
      expr = perRow (n: _: firesAtApplication (genAssemble.${n} 1));
      expected = perRow (_: _: true);
    };
    # The live control: `{ }` forms the door and the contributions answer.
    test-control-the-empty-options-answer = {
      expr = perRow (n: _: answers (genAssemble.${n} { } layers));
      expected = perRow (_: _: true);
    };
    # D3: the published contract and the functor-aware reader agree with the row.
    test-each-door-publishes-its-contract = {
      expr = perRow (
        n: _: {
          inherit (genAssemble.${n}.__contract) optional open required;
          args = prelude.functionArgs genAssemble.${n};
        }
      );
      expected = perRow (
        _: r: {
          inherit (r) optional;
          open = false;
          required = [ ];
          args = builtins.listToAttrs (map (f: prelude.nameValuePair f true) r.optional);
        }
      );
    };
    # G3: `strategies` reaches the folded content, and the partial application agrees with the full
    # call. `kinds` and `strict` are covered by G4 and by `protocol.nix`'s cells over them.
    test-a-non-default-option-reaches-the-result = {
      expr = perRow (
        n: r:
        let
          f1 = genAssemble.${n} appended;
        in
        {
          agree = r.observe (f1 layers) == r.observe (genAssemble.${n} appended layers);
          differ = r.observe (f1 layers) != r.observe (genAssemble.${n} { } layers);
        }
      );
      expected = perRow (
        _: _: {
          agree = true;
          differ = true;
        }
      );
    };
  };
}
