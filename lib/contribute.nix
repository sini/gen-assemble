# THE CONTRIBUTION PROTOCOL AND ITS UNION POINT.
#
# A contribution is what one layer hands over: some graph shape, some labelled dimensions, and some
# content. The union combines a LIST of them into the single argument the constructor takes. Every
# framework that assembles a node set from several sources otherwise writes this, and writes it the
# same way, which is the whole reason it lives here rather than in each of them.
#
# ★ TWO HALVES, GOVERNED DIFFERENTLY, AND READING THEM AS ONE OPERATION IS THE DESIGN ERROR THIS
# LIBRARY EXISTS TO NOT MAKE.
#
#   SHAPE — the graphs — combines by COMMUTATIVE UNION. Mokhov 2017's monoid: overlay is
#   commutative, associative and idempotent, so which layer went first cannot change the node set or
#   the edge relations. A boundary mark is structural, and shape must not depend on arrival.
#
#   CONTENT — `decls`, `types`, and the VERTEX SEQUENCE — arrives as an ORDERED list and folds by
#   POSITIONAL AUTHORITY. The substrate's fold is an ordered fold with no strength lattice, and an
#   ordered contribution list is plain data. So two layers contributing `decls` for one node is NOT
#   an error: they are handed over in the declared order and the fold settles them.
#
# ★ THE VERTEX SEQUENCE IS CONTENT, and that classification is what makes this protocol compose with
# the constructor's published order. The sequence is derived from graph-shaped inputs but it is
# carried like content: it rides this ordered list, exactly as `decls` and `types` do. Permuting the
# list moves the sequence while leaving the node set and every node value untouched — which is why
# the commutative-union ruling above stands unchanged.
#
# ★ THE ORDER IS A PARAMETER OF THE ASSEMBLY, never derived from a kind hierarchy. Deriving it from
# global → class → host → user would re-import the topology the agnosticism law forbids. It must
# also be invariant under presentation order; that obligation belongs to whoever builds the list.
#
# ★ THE CONTRIBUTION RECORD IS TOTAL, AND A KEY THE PROTOCOL DOES NOT CARRY IS REFUSED BY NAME. A
# constructor that reads the keys it knows and drops the rest cannot enforce the shape it publishes:
# the drop is silent, so a caller who mistypes a field, or who offers one the protocol does not
# carry, gets an empty result and a green evaluation — a layer's content vanishing with nothing
# said, entered through the front door. The refusal is therefore a property of the CONSTRUCTOR and
# not of a later scan, so the bad intermediate never forms.
{
  prelude,
  scope,
  algebra,
}:
let
  reserved = [
    {
      label = "P";
      relation = "the containment relation, which travels as a contribution's `parentGraph`";
    }
    {
      label = "I";
      relation = "the import relation, which travels as a contribution's `importGraph`";
    }
  ];

  # The whole of what a contribution may carry. `parentGraph` and `importGraph` are GRAPHS, not
  # labels — the relations they carry are the substrate's own, and a layer contributes to them by
  # handing over a graph that the union overlays commutatively. The LABEL space is what the
  # reservation below closes, and the two are different things: refusing the label `P` does not stop
  # a layer contributing containment, it stops a layer smuggling containment in under a name the
  # substrate privileges, where it would displace what another layer declared.
  #
  # There is no `vertices` key and no need for one: an isolated vertex is a graph, and it travels as
  # `parentGraph = scope.vertex id` like every other piece of shape. A second spelling for it would
  # be a second way to say the same thing, and the constructor's own argument has none either.
  contributionKeys = [
    "name"
    "parentGraph"
    "importGraph"
    "edgeGraphs"
    "decls"
    "types"
  ];

  # THE VALIDATING CONSTRUCTOR. It refuses rather than repairs, and it refuses at the point of
  # construction, which is what keeps a contribution the protocol cannot honour from ever existing.
  #
  # ★ THE NAME IS REQUIRED, AND IT IS CHECKED FIRST BECAUSE EVERY OTHER REFUSAL IS STATED IN IT. A
  # defaulted name silently converts "the refusal names both contributors" into a constant, so that
  # property survives only if a contribution cannot exist without a name to be named by. An EMPTY
  # name is refused on the same ground and not defaulted: it is writable, it reads like a
  # declaration, and it names nothing — the naming property degrades exactly as it does when the
  # field is absent, which is the shape a defaulted emptiness always has.
  #
  # ★ A CONTRIBUTION WITH NO NAME IS REFUSED BY ITS POSITION, a coordinate this protocol already
  # carries rather than one invented for the diagnostic: the contribution list is ORDERED and
  # content folds by positional authority, so a position is a fact about the assembly the caller
  # declared and can act on.
  normalise =
    position: c:
    let
      offered = builtins.attrNames c;
      unknown = prelude.filter (k: !(builtins.elem k contributionKeys)) offered;
      at = "the contribution at index ${toString position} of the list";
    in
    if !(c ? name) then
      throw "gen-assemble: ${at} offers no `name`, and the keys it does offer are ${builtins.toJSON offered}. Every refusal this protocol makes names the contributions it is about, because \"some layer\" is not actionable — so a contribution that cannot be named is refused before it can degrade one."
    else if c.name == "" then
      throw "gen-assemble: ${at} offers an EMPTY `name`. An empty name is writable and it names nothing, so it carries a refusal's actionability away exactly as an absent one does while reading like a declaration."
    else if unknown != [ ] then
      throw "gen-assemble: the contribution `${c.name}` offers ${builtins.toJSON unknown}, which this protocol does not carry. The record is total over ${builtins.toJSON contributionKeys}, and an unknown key is refused here rather than dropped, because a dropped key is a layer's content vanishing with nothing said. An isolated vertex travels as `parentGraph = scope.vertex \"<id>\"`, not as a key of its own."
    else
      {
        inherit (c) name;
        parentGraph = c.parentGraph or scope.empty;
        importGraph = c.importGraph or scope.empty;
        edgeGraphs = c.edgeGraphs or [ ];
        decls = c.decls or { };
        types = c.types or { };
      };

  # Each contributed edge graph tagged with the contribution that offered it. The tag is the only
  # reason a name travels past the constructor, and it is what makes the refusal below actionable.
  labelledEdgeGraphs =
    cs: prelude.concatMap (c: map (g: g // { contributor = c.name; }) c.edgeGraphs) cs;

  # THE COLLISION FACTS AS DATA: every label claimed by more than one contribution, with the
  # contributions that claimed it. The refusal RENDERS this rather than computing it inline, so that
  # a diagnostic naming both contributors is a property something can read rather than one a reader
  # has to take on the message's word.
  collisionsOf =
    labelled:
    let
      byLabel = builtins.groupBy (g: g.label) labelled;
    in
    map (l: {
      label = l;
      contributors = map (g: g.contributor) byLabel.${l};
    }) (prelude.filter (l: builtins.length byLabel.${l} > 1) (builtins.attrNames byLabel));

  # The same facts read from a raw contribution list, for a caller that wants them ahead of the
  # refusal — the union itself composes the two halves above directly and normalises once.
  collisions =
    contributions: collisionsOf (labelledEdgeGraphs (prelude.imap0 normalise contributions));

  union =
    {
      contributions,
      strategies ? { },
    }:
    let
      cs = prelude.imap0 normalise contributions;

      # ── THE LABEL REFUSALS, at the protocol boundary ──
      # A label names a DIMENSION, not a node. Two layers claiming one label is a genuine collision
      # with no order semantics to resolve it — unlike `decls`, where the ordered fold IS the
      # resolution — so it throws, and it names both contributors because "some layer" is not
      # actionable. The names it prints are the declared ones: the constructor above refuses a
      # contribution that has none, so there is no default for this refusal to degenerate into.
      labelled = labelledEdgeGraphs cs;

      offendingReserved = prelude.filter (r: prelude.any (g: g.label == r.label) labelled) reserved;

      colliding = collisionsOf labelled;

      checkedLabels =
        if offendingReserved != [ ] then
          throw "gen-assemble: a contribution offers the reserved label(s) ${
            builtins.toJSON (map (r: r.label) offendingReserved)
          }. ${
            prelude.concatMapStringsSep " " (
              r:
              "`${r.label}` is ${r.relation}, and a contribution offering it under that name would displace what another layer declared — contribute those edges as the named graph instead."
            ) offendingReserved
          }"
        else if colliding != [ ] then
          throw "gen-assemble: ${
            prelude.concatMapStringsSep "; " (
              c:
              "the label `${c.label}` is claimed by more than one contribution (${prelude.concatStringsSep ", " c.contributors})"
            ) colliding
          }. A label names a dimension rather than a node, so two claims on one label have no order semantics to settle them — merge the graphs into a single contribution, or give each its own label."
        else
          map (g: builtins.removeAttrs g [ "contributor" ]) labelled;

      # SHAPE: commutative union. The result is a graph, and which layer went first is not
      # observable in the node set or the edge relations.
      shapeOf = f: scope.overlays (map f cs);
    in
    {
      parentGraph = shapeOf (c: c.parentGraph);
      importGraph = shapeOf (c: c.importGraph);
      edgeGraphs = checkedLabels;

      # CONTENT: the ordered fold, least-specific first, per the substrate's positional authority.
      # Two layers contributing for one node co-contribute; the fold settles them by position.
      decls = foldContent {
        field = "decls";
        inherit cs strategies;
      };
      types = foldContent {
        field = "types";
        inherit cs strategies;
      };
    };

  # The per-node ordered fold. `foldLayers` settles ONE record across ordered layers, so it is
  # applied per node id, over exactly the layers that named that id, in contribution order.
  foldContent =
    {
      field,
      cs,
      strategies,
    }:
    let
      layersFor = id: prelude.filter (l: l != null) (map (c: c.${field}.${id} or null) cs);
      ids = builtins.attrNames (
        builtins.foldl' (acc: c: acc // builtins.mapAttrs (_: _: true) c.${field}) { } cs
      );
    in
    prelude.genAttrs ids (
      id:
      let
        layers = layersFor id;
      in
      # A field whose contributions are not records is settled by position alone: last declared
      # wins, which is the same rule the record fold applies and the only one available to a scalar.
      if prelude.any (l: !(builtins.isAttrs l)) layers then
        builtins.elemAt layers (builtins.length layers - 1)
      else
        algebra.record.foldLayers {
          inherit strategies layers;
        }
    );
in
{
  inherit
    union
    reserved
    normalise
    collisions
    ;
}
