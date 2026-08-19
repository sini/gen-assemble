# THE SURFACE, held to an exact list.
#
# gen-assemble shipped with an EMPTY surface while its constructs were blocked on three open
# substrate defects, two of which fail SILENTLY. All three are now landed, and the construction
# that answers them — a refusal that names the record when a pinned substrate fails a property —
# is content, so the content exists and the surface with it.
#
# The list is EXACT rather than a count, so a new export lands as a failing test with the author
# obliged to state it here, in `AGENTS.md` and in the canonical reference in the same change.
#
# ★ AND THE OBLIGATION TOWARDS `AGENTS.md` IS DISCHARGED BY CONSTRUCTION RATHER THAN BY DILIGENCE.
# A tripwire that holds the library to a list, while the document describing that list is bound to
# nothing, catches the library drifting from the list and never the document drifting from the
# library — so the sheet can go on publishing a surface the library stopped having, silently, which
# is the failure this repository keeps naming. The sheet's own drift-check output is JSON for that
# reason: it is one artefact, read by a reader and asserted here.
{
  genAssemble,
  prelude,
  scope,
  lib,
  ...
}:
let
  algebra = null; # not forced by the cells below; the surface is settled before any fold runs

  toolkitSurface = [
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

  agentsSheet = builtins.readFile ../../AGENTS.md;

  # The sheet's drift-check block: the output it publishes as the library's surface, taken from the
  # document rather than described from it.
  documentedSurface = builtins.fromJSON (
    lib.head (lib.splitString "```" (lib.elemAt (lib.splitString "```json" agentsSheet) 1))
  );

  mentions = name: lib.hasInfix "`${name}`" agentsSheet;
in
{
  flake.tests.surface = {
    test-lib-exports-exactly-the-toolkit = {
      expr = builtins.attrNames genAssemble;
      expected = toolkitSurface;
    };

    # ── THE SHEET AND THE LIBRARY, BOUND TOGETHER ──
    # Both halves are asserted against the same literal in one cell, so neither can drift onto the
    # other and neither side can pass by being empty.
    test-agents-md-publishes-the-exported-surface = {
      expr = {
        documented = documentedSurface;
        exported = builtins.attrNames genAssemble;
      };
      expected = {
        documented = toolkitSurface;
        exported = toolkitSurface;
      };
    };
    # And each name is written into the sheet's prose as well, so the block cannot agree with the
    # library while the section around it describes something else.
    test-agents-md-names-every-export-in-its-prose = {
      expr = prelude.filter (n: !(mentions n)) toolkitSurface;
      expected = [ ];
    };
    # CONTROL: the mention predicate reads FALSE for a name the sheet does not carry, in the same
    # run. An absence over a predicate that matches everything is not an absence.
    test-control-the-mention-predicate-can-read-false = {
      expr = mentions "notAToolkitExport";
      expected = false;
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
