# THE SECOND TEST OUTPUT — cells whose subject is an ERROR MESSAGE, and why they cannot live in
# `flake.tests`.
#
# THAT the assembly refuses on an unmet substrate precondition is a boolean, and `ci/tests/protocol.nix`
# already asserts it with `tryEval` (`test-an-unmet-substrate-is-refused-by-name`). WHICH precondition
# failed, and WHETHER the refusal still names the record a consumer needs to move the pin, is a claim
# about the message — and `tryEval` returns `{ success, value }` and DISCARDS the text, so a suite of
# booleans alone is equally satisfied by a `require` that refuses for the wrong reason, or that stops
# naming the record, as by the one landed today. nix-unit's `expectedError` is the assertion for that,
# and this is where it goes.
#
# ★ WHY A SECOND OUTPUT RATHER THAN A SECOND SUITE. The batch asserter behind `checks.default`
# evaluates `t.expr == t.expected` UNCONDITIONALLY and quantifies over `config.flake.tests` and
# nothing else, so a cell with no `expected` and a throwing `expr` CRASHES that gate rather than
# failing it. Hosting these on `flake.testsError` puts them outside that quantifier while keeping
# them live on the nix-unit path. The split is structural, not conventional: this file is not under
# ./tests, which is the whole of `testModules`.
#
#   nix-unit --flake ./ci#tests        # the suites
#   nix-unit --flake ./ci#testsError   # these cells
#
# ★★ `expectedError.msg` IS SEARCHED, NOT WHOLE-MATCHED, so a pattern naming a PREFIX of the message
# passes against a message that says something else after it — which would make this cell agree with
# the very rewording it exists to catch. The pattern is anchored at both ends and built by ESCAPING
# THE LITERAL TEXT rather than by hand.
{
  genAssemble,
  genAssembleUnmet,
  lib,
  ...
}:
let
  exactly = msg: "^" + lib.escapeRegex msg + "$";

  # `genAssembleUnmet` is this library over `gen-scope` pinned one commit before the declared vertex
  # order landed — at that pin the substrate does not publish `buildRoots` at all, so the ENTRY check
  # (`den-hoag-u1sf`) is the one unmet precondition, and the three checks it gates are correctly
  # UNEVALUATED rather than reported as additional failures (`ci/tests/protocol.nix`'s own
  # `test-an-unevaluable-probe-is-not-reported-as-a-failing-property` is the live control for that
  # half). `require` never forces the contribution list before it throws — the check is a property of
  # the pinned substrate, not of what is being assembled — so an empty list reaches the same message.
  unmetSubstrateNamesTheRecord =
    "gen-assemble: the pinned gen-scope does not meet 1 of this library's 1 substrate preconditions, "
    + "so an assembly built on it would be wrong with no diagnostic. den-hoag-u1sf: the substrate "
    + "must publish `buildRoots` — a pin predating it carries the retired constructor, whose result "
    + "is a bare node map with no declared order in it, so nothing downstream can read an order that "
    + "was never returned. Move the `scope` pin to a substrate where these hold.";
in
{
  flake.testsError = {
    # ── THE IDENTIFIER DOORS (den-hoag-bkdkg) ──
    # A record handed where a name goes — the node VALUE in place of its identifier — used to abort
    # past `tryEval` with the evaluator's coercion error. Each door now refuses it by its own name.
    # `idsOf` is read through `length` because the refusal must reach a caller that never forces an
    # element; a guard living inside the elements would pass a deep-forcing cell and fail this one.
    test-mkId-refuses-a-record-type-by-name = {
      expr = genAssemble.mkId { name = "a"; } "web1";
      expectedError.msg = exactly "gen-assemble.mkId: the type is a set, expected a string";
    };
    test-mkId-refuses-a-record-name-by-name = {
      expr = genAssemble.mkId "host" { name = "a"; };
      expectedError.msg = exactly "gen-assemble.mkId: the name is a set, expected a string";
    };
    test-parseId-refuses-a-record-by-name = {
      expr = genAssemble.parseId { name = "a"; };
      expectedError.msg = exactly "gen-assemble.parseId: the identifier is a set, expected a string";
    };
    test-idsOf-refuses-a-record-name-before-any-element-is-read = {
      expr = builtins.length (genAssemble.idsOf "host" [ { name = "a"; } ]);
      expectedError.msg = exactly "gen-assemble.idsOf: a name is a set, expected a string";
    };
    test-idsOf-refuses-a-record-type-by-name = {
      expr = builtins.length (genAssemble.idsOf { name = "a"; } [ "web1" ]);
      expectedError.msg = exactly "gen-assemble.idsOf: the type is a set, expected a string";
    };

    test-unmet-substrate-refusal-names-the-record = {
      expr = genAssembleUnmet.assemble { contributions = [ ]; };
      expectedError.msg = exactly unmetSubstrateNamesTheRecord;
    };
  };
}
