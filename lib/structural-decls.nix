# THE STRUCTURAL DECLARATIONS THE EVALUATOR DEMANDS.
#
# These two bodies were measured expression-identical across two independent repositories, one of
# them carrying a comment that the evaluator's completeness helpers require them. They are not
# domain code — no framework chose them, and none can omit them: a consumer that leaves `children`
# out gets a throw from every structural query, and one that leaves `imports` out ships a relation
# nothing recomputes.
#
# ★ THE NAMES ARE `children` AND `imports`, and they are the names the EVALUATOR READS rather than
# the names it reserves. A body supplied under a reserved-but-unread name either makes the evaluator
# throw for an unknown attribute or ships something nothing reads, while each framework's own
# hand-written version stays silently stale. Supplying under the read name is the whole point.
#
# ★ THEY ARE EXPORTED UNDER A NESTED CARRIER, never as flat top-level names. The substrate's surface
# is flat and already publishes `children`; a flat name here would mean two different things under
# one spelling at a consumer's call site, which is the re-handing hazard the boundary rule names.
{ prelude }:
{
  # `structuralDecls nodes` ⇒ the attribute set a consumer merges into its own `attributes`.
  # It takes the NODE MAP — `scope.nodes` from the constructor's record — because the child relation
  # is a filter over it and nothing else here needs the declared order.
  structuralDecls = nodes: {
    children = _self: id: prelude.filterAttrs (_: n: n.parent == id) nodes;

    # The import relation's DEFAULT is empty, and a framework that has one overrides this. It is
    # supplied at all so the attribute exists under the name the resolver traverses: an absent
    # `imports` is not an empty import set, it is an unknown attribute.
    imports = _self: _id: [ ];
  };
}
