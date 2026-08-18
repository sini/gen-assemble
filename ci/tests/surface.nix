# The shell tripwire.
#
# gen-assemble ships with an EMPTY export surface on purpose: every specified construct is blocked
# on an open substrate defect, two of which fail SILENTLY, and the construction that answers them
# refuses to evaluate by name while a precondition is unmet. That refusal is content. An export
# landed ahead of it would be a construct with no armed refusal behind it. This suite makes the
# empty surface a checked fact rather than a note, so the first export lands as a FAILING TEST —
# the author is then obliged to state the surface in `AGENTS.md` and in the canonical reference in
# the same change, and a silent widening cannot happen.
#
# When content lands: replace the empty expectation with the real surface, not the suite.
{ genAssemble, ... }:
{
  flake.tests.surface = {
    test-lib-exports-nothing = {
      expr = builtins.attrNames genAssemble;
      expected = [ ];
    };

    # The standalone (non-flake) root entry and the `lib/` entry are one value. The two entries
    # diverging is the classic gen root-file drift; asserting equality keeps them one surface as the
    # library grows past the zero-dependency shape.
    test-standalone-entry-matches-lib = {
      expr = import ../.. == import ../../lib;
      expected = true;
    };
  };
}
