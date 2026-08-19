# THE SUBSTRATE PRECONDITIONS, CHECKED AS PROPERTIES OF THE PINNED SUBSTRATE.
#
# This library is specified against three substrate defects, two of which fail SILENTLY. A toolkit
# that built green on a substrate carrying them would hand a consumer a wrong answer with nothing
# said anywhere: a relation served stale from a prior evaluation, a declared parent graph discarded,
# a declared vertex order replaced by codepoint residue. "It is a precondition" is a statement, not
# a mechanism, so the mechanism is here — the assembly REFUSES TO EVALUATE BY NAME while any of them
# is unmet, and each refusal names the record so a consumer knows which pin to move.
#
# ★ EACH CHECK IS A PROPERTY OF THE SUBSTRATE, NEVER A VERSION COMPARISON. A revision string says
# nothing about a fork, a patch or a local override, and it goes stale the moment the substrate
# moves for an unrelated reason. What is asserted here is the behaviour the assembly depends on.
#
# ★ THE ORDER PROBE IS REVERSE-ALPHABETICAL ON PURPOSE. A substrate that destroys the declared
# order answers in codepoint order, so an alphabetically-declared probe passes on the broken
# substrate and the check reads clean while the defect is live. The probe declares `b` before `a`
# and requires `[ "b" "a" ]`; on the defective substrate it gets `[ "a" "b" ]`.
{ prelude, scope }:
let
  # ★ A SUBSTRATE MAY NOT CARRY THE CONSTRUCTOR AT ALL, and that is the FIRST thing to establish.
  # Probing a property of a function that is not there raises a bare missing-attribute error from
  # inside the probe, which is exactly the undiagnosed failure these checks exist to replace — so
  # every probe below is guarded on the entry existing, and its absence is itself a named finding.
  hasConstructor = scope ? buildRoots;

  # Does a contribution offering a reserved label survive to the node set, or is it refused?
  reservedLabelIsRefused =
    hasConstructor
    && !(builtins.tryEval (
      builtins.deepSeq (scope.buildRoots {
        parentGraph = scope.edge "a" "root";
        edgeGraphs = [
          {
            label = "P";
            graph = scope.edge "a" "HIJACKED";
          }
        ];
      }) 1
    )).success;

  # Does the declared vertex order survive the constructor? Declared `b` then `a`.
  declaredOrderSurvives =
    let
      probe = builtins.tryEval (
        assert hasConstructor;
        (scope.buildRoots {
          parentGraph = scope.overlays [
            (scope.vertex "b")
            (scope.vertex "a")
          ];
        }).nodeOrder
      );
    in
    probe.success
    &&
      probe.value == [
        "b"
        "a"
      ];

  # Is the relation the resolver traverses classified STRUCTURAL, and so ineligible for stale reuse?
  importRelationIsStructural =
    let
      probe = builtins.tryEval (scope.structural "imports");
    in
    probe.success && probe.value;

  # ★ A PROBE THAT CANNOT RUN IS NOT A PROPERTY THAT FAILS, and conflating the two over-reports.
  # Two of the three probes below go THROUGH the constructor, so on a substrate that does not
  # publish it they are UNEVALUABLE rather than unmet — and reporting them as failures would tell a
  # consumer that two defects are live on a pin where both were in fact repaired. So the entry check
  # comes first and stands alone; the properties it gates are only asserted where they can be read.
  entryCheck = {
    met = hasConstructor;
    record = "den-hoag-u1sf";
    property = "the substrate must publish `buildRoots` — a pin predating it carries the retired constructor, whose result is a bare node map with no declared order in it, so nothing downstream can read an order that was never returned";
  };

  gatedChecks = [
    {
      met = importRelationIsStructural;
      record = "den-hoag-aznm";
      property = "`structural \"imports\"` must be true — the relation the resolver traverses must be classified structural, or it is eligible for stale warm reuse and the import relation is served from a prior evaluation with nothing said";
    }
    {
      met = reservedLabelIsRefused;
      record = "den-hoag-r9ne";
      property = "a contribution offering the reserved label `P` must be refused by the constructor — otherwise the declared parent graph is silently displaced by the caller's label";
    }
    {
      met = declaredOrderSurvives;
      record = "den-hoag-u1sf";
      property = "the declared vertex order must survive the constructor — a two-vertex probe declared `b` then `a` must answer `[ \"b\" \"a\" ]`, not the codepoint `[ \"a\" \"b\" ]`";
    }
  ];

  checks = [ entryCheck ] ++ (if hasConstructor then gatedChecks else [ ]);

  unmet = prelude.filter (c: !c.met) checks;
in
{
  inherit checks unmet;

  # Force this ahead of any assembly work. It returns its argument, so a caller binds through it
  # rather than remembering to call it: `require (assemble …)` cannot be written without the check
  # being demanded first.
  require =
    value:
    if unmet == [ ] then
      value
    else
      throw "gen-assemble: the pinned gen-scope does not meet ${toString (builtins.length unmet)} of this library's ${toString (builtins.length checks)} substrate preconditions, so an assembly built on it would be wrong with no diagnostic. ${
        prelude.concatMapStringsSep " " (c: "${c.record}: ${c.property}.") unmet
      } Move the `scope` pin to a substrate where these hold.";
}
