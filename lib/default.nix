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
# ── THE SUBSTRATE ARRIVES INJECTED, AND THAT IS THE BOUNDARY RULE, NOT A CONVENIENCE ──
# Only plain data crosses a gen↔gen boundary. Constructing with injected libraries is conformant;
# re-handing one verbatim is what the rule rejects — so this library takes `prelude`, `scope` and
# `algebra` as values and constructs inside the consumer's own evaluation. It re-exports none of
# them, and in particular it does not republish the substrate's constructor under a name of its own.
#
# ── WHAT IS REFUSED BY NAME, and why each is refused rather than merely absent ──
#   identity minting  — the substrate has exactly one minting authority; a second would make the
#                       count of authorities a fact about call sites instead of about the dataflow.
#   the evaluation    — three measured assemblies differ IN KIND, not by parameters, so a shared
#                       evaluator would be one algorithm pretending to be three.
#   a canned graph    — a contribution dimension is exactly the per-caller part.
#   schema validation — it evaluates, which limb 3 forbids.
{
  prelude,
  scope,
  algebra,
}:
let
  preconditions = import ./preconditions.nix { inherit prelude scope; };
  contribute = import ./contribute.nix { inherit prelude scope algebra; };
  identifier = import ./identifier.nix { inherit prelude; };
  structural = import ./structural-decls.nix { inherit prelude; };

  # THE ASSEMBLY: the protocol's one entry. It unions the contributions and hands the result to the
  # substrate's constructor, and it is bound THROUGH the precondition check so that a substrate
  # carrying one of the three named defects refuses here rather than serving a wrong answer.
  #
  # It returns the substrate's own record — `{ nodes, nodeOrder }` — unchanged. That is plain data,
  # and re-wrapping it would put a second shape in front of a consumer for no gain.
  assemble =
    {
      contributions,
      strategies ? { },
      strict ? true,
    }:
    preconditions.require (
      scope.buildRoots (contribute.union { inherit contributions strategies; } // { inherit strict; })
    );
in
{
  inherit assemble;

  # The union alone, for a consumer that wants the merged contribution before it reaches the
  # constructor — which is also the only point at which the union's order-independence is
  # observable, since the constructor's published order is content and moves with the list.
  inherit (contribute) union reserved;

  inherit (identifier)
    mkId
    parseId
    idsOf
    separator
    ;
  inherit (structural) structuralDecls;

  # The precondition checks, exposed so a consumer can read WHICH substrate properties this library
  # depends on rather than discovering them from a throw.
  substratePreconditions = preconditions.checks;
}
