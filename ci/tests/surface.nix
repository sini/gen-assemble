# THE SURFACE, held to an exact list.
#
# gen-assemble shipped with an EMPTY surface while its constructs were blocked on three open
# substrate defects, two of which fail SILENTLY. All three are now landed, and the construction
# that answers them — a refusal that names the record when a pinned substrate fails a property —
# is content, so the content exists and the surface with it.
#
# The list is EXACT rather than a count, so a new export lands as a failing test with the author
# obliged to state it here, in `AGENTS.md` and in the canonical reference in the same change.
{
  genAssemble,
  prelude,
  scope,
  ...
}:
let
  algebra = null; # not forced by the two cells below; the surface is settled before any fold runs
in
{
  flake.tests.surface = {
    test-lib-exports-exactly-the-toolkit = {
      expr = builtins.attrNames genAssemble;
      expected = [
        "assemble"
        "idsOf"
        "mkId"
        "parseId"
        "reserved"
        "separator"
        "structuralDecls"
        "substratePreconditions"
        "union"
      ];
    };

    # The standalone (non-flake) root entry and the `lib/` entry are ONE SURFACE. The two entries
    # diverging is the classic gen root-file drift.
    #
    # ★ The assertion is over the APPLIED surfaces, not over the entries themselves: both are now
    # functions of the injected substrate, and two Nix lambdas are never equal — so `entry == entry`
    # would read `false` on a correct library and could not distinguish drift from the language. The
    # applied form is also the stronger claim: it is the surface a consumer actually receives.
    test-standalone-entry-matches-lib = {
      expr =
        let
          applied =
            entry:
            builtins.attrNames (entry {
              inherit prelude scope algebra;
            });
        in
        applied (import ../..) == applied (import ../../lib);
      expected = true;
    };

    # The formals are the injected substrate and nothing else — the boundary rule's shape, checked
    # rather than described.
    test-the-library-takes-its-substrate-injected = {
      expr = builtins.attrNames (builtins.functionArgs (import ../../lib));
      expected = [
        "algebra"
        "prelude"
        "scope"
      ];
    };
  };
}
