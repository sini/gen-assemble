# gen-assemble — the SHARED FRAMEWORK TOOLKIT.
#
# A framework that assembles one node set from many layers' contributions writes the same protocol
# around the same call every time. What is genuinely per-caller is the contribution DIMENSION and
# the COMPUTATION; what is duplicated is the protocol around the call — the union, the identifier
# convention, and the structural boilerplate the evaluator demands. This library holds the second
# and never the first.
#
# THE MEMBERSHIP CRITERION, which is what keeps a shared toolkit from becoming a junk drawer:
# a construct belongs here iff (1) EVERY framework that assembles a graph must otherwise write it;
# (2) NOTHING IN THE SUBSTRATE IS DEFINED IN ITS TERMS — the dependence runs one way, from this
# library down into the substrate and never back; and (3) it does not EVALUATE. Identity minting,
# the evaluation itself, a canned host/env graph, and schema validation each fail one of the three
# and are refused BY NAME rather than merely absent.
#
# Theory: Mokhov 2017, *Algebraic Graphs with Class* — the graph-shape half combines by the
# commutative, associative, idempotent monoid, so shape must not depend on arrival order. The
# content half is the opposite discipline: an ORDERED contribution list folded by positional
# authority, with the order a parameter of the assembly and never derived from a kind hierarchy.
# Reading the two halves as one operation is the design error this library exists to not make.
#
# THE SURFACE IS EMPTY, AND DELIBERATELY SO. The toolkit's constructs — the contribution protocol
# and its union, the identifier convention, and the structural declarations supplied under the
# names the evaluator actually reads — are specified, and each is blocked on a named, open
# substrate defect. Two of those three fail SILENTLY, so a library that built green against them
# would ship a consumer a wrong answer with no diagnostic anywhere. The specified construction
# refuses to evaluate by name while a precondition is unmet; that refusal is content, and content
# is what has not been written. An export landed ahead of it would be a construct with no armed
# refusal behind it, which is the one shape this design is not allowed to ship.
#
# `ci/tests/surface.nix` holds this file to the empty surface, so the first export arrives as a
# FAILING TEST rather than as a silent widening — and the author is then obliged to state the new
# surface in `AGENTS.md` and in the canonical reference in the same change.
{ }
