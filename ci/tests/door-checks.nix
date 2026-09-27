# THE CLOSED-DOOR CHECKS (den-hoag-7gp66 P1) — every published door catches its own violations.
#
# A native closed formal (`{ contributions, strategies ? {} }:`) aborts UNCATCHABLY on an unknown
# or a missing argument — not even `builtins.tryEval` sees it, which is ADR-0025 item 1's named
# defect. `assemble` and `union` — the two closed doors the census counts for this library — now
# take a bare positional formal and apply gen-prelude's shared `checkOptions`/`checkRequired`
# instead, so the same violations are NAMED and CATCHABLE.
#
# ★ BOTH DOORS ARE MIXED (`contributions` required, the rest optional) and stay CLOSED on both
# axes: `checkOptions` composed over `checkRequired`, so an unknown field is refused rather than
# admitted. Neither door in this library is RECORD-only, so the "extra field admitted" family
# member (R5's stated price) has no applicable door here — see the report for the door census.
#
# WHICH refusal fired is a claim about the message and `tryEval` yields only `success`; the byte
# goldens naming each door (R6) live in `ci/tests-error.nix`'s `flake.testsError`.
{
  genAssemble,
  ...
}:
let
  inherit (genAssemble) assemble union;

  # WHNF only: each door forces its check at the call, so the refusal meets the caller there — a
  # bare `(assemble args).decls` would never touch a violation on a field this cell does not read.
  refusesCatchably = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
  answers = e: (builtins.tryEval (builtins.deepSeq e null)).success;
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

    # union — MIXED class (checkOptions over checkRequired).
    test-union-missing-required-field-refused-catchably = {
      expr = refusesCatchably (union {
        strategies = { };
      });
      expected = true;
    };
    test-union-unknown-option-refused-catchably = {
      expr = refusesCatchably (union {
        contributions = [ ];
        zzasm7q2v = 1;
      });
      expected = true;
    };
    test-union-non-set-refused-catchably = {
      expr = refusesCatchably (union 1);
      expected = true;
    };
    test-union-valid-call-is-unchanged = {
      expr = (union { contributions = [ ]; }).decls;
      expected = { };
    };

    # assemble — MIXED class.
    test-assemble-missing-required-field-refused-catchably = {
      expr = refusesCatchably (assemble {
        kinds = null;
      });
      expected = true;
    };
    test-assemble-unknown-option-refused-catchably = {
      expr = refusesCatchably (assemble {
        contributions = [ ];
        zzasm7q2v = 1;
      });
      expected = true;
    };
    test-assemble-non-set-refused-catchably = {
      expr = refusesCatchably (assemble 1);
      expected = true;
    };
    test-assemble-valid-call-is-unchanged = {
      expr = answers (assemble {
        contributions = [ ];
      });
      expected = true;
    };
  };
}
