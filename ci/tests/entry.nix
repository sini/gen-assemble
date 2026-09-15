# THE STANDALONE ENTRY'S OWN DEFAULTS, FORCED — the cell no other cell in this repository can be.
#
# `surface.nix` already compares the root entry against `../lib`, but it does so with every
# dependency formal SUPPLIED, so the shim's `ci/flake.lock`-backed defaults are never forced. That is
# precisely where this library's non-flake contract lives: `import ./. { }` must produce the same
# library the flake path does, resolving every dependency from `./ci/flake.lock` with no argument
# supplied and no search path consulted.
#
# ★★ THE CALL IS ARITY-DISPATCHED, NOT `import ../.. { }`. A dependency-free library publishes its
# root as a bare VALUE rather than a function, so the literal application is wrong at those roots by
# design; `if builtins.isFunction v then v { } else v` is the one form total over the roster, and it
# is the same construct the shim's own `dep` uses. Writing the literal here would make this cell
# assert a call convention the ecosystem deliberately does not have.
#
# ★★★ THIS CELL IS NOT HERMETIC, AND THAT IS ITS WHOLE POINT. Forcing the defaults IS
# `builtins.fetchTree`, so this cell reaches the network — the accepted price of measuring the thing
# at all, and the reason it sits apart from the suites that must not. It remains PURE: `fetchTree`
# on a locked node is narHash-addressed, with no channel and no `<…>`.
#
# ★ THE FORCE DEPTH IS EACH MEMBER'S WHNF, AND HERE THAT REACHES THE RESOLVER — measured, not
# assumed: this library publishes `substratePreconditions` as a VALUE derived from `scope`, so the
# force crosses into the defaults. Driven both ways with the shim's `src` seam sealed by a `throw`:
# sealed ⇒ rc 1 reported at `gen-scope`, open ⇒ rc 0. A library whose whole surface is lambdas would
# need a CALL here instead, because no force depth enters a lambda.
{ genAssemble, ... }:
let
  entry = import ../..;
  dispatched = if builtins.isFunction entry then entry { } else entry;
in
{
  # The two entry paths are ONE library. `genAssemble` is built from ci's flake inputs, `dispatched`
  # from the same `ci/flake.lock` read as data — so this compares the two suppliers of one
  # construction rather than an expression with itself.
  flake.tests.entry.test-the-defaulted-entry-publishes-the-flake-surface = {
    expr = builtins.attrNames dispatched;
    expected = builtins.attrNames genAssemble;
  };

  # The defaults are RESOLVED, not merely declared. Neither `gen-prelude` nor `gen-algebra` is a root
  # input of this repository's ci lock — both are reached THROUGH gen-scope — so a name-shaped
  # default would abort here with `attribute 'gen-prelude' missing` instead of passing.
  flake.tests.entry.test-the-defaulted-entry-resolves-its-dependencies-from-its-ci-lock = {
    expr = builtins.deepSeq (builtins.mapAttrs (_: builtins.typeOf) dispatched) "resolved";
    expected = "resolved";
  };
}
