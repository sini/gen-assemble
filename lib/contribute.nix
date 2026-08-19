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

  # A contribution's own defaults. `parentGraph` and `importGraph` are GRAPHS, not labels — the
  # relations they carry are the substrate's own, and a layer contributes to them by handing over a
  # graph that the union overlays commutatively. The LABEL space is what the reservation below
  # closes, and the two are different things: refusing the label `P` does not stop a layer
  # contributing containment, it stops a layer smuggling containment in under a name the substrate
  # privileges, where it would displace what another layer declared.
  normalise = c: {
    parentGraph = c.parentGraph or scope.empty;
    importGraph = c.importGraph or scope.empty;
    edgeGraphs = c.edgeGraphs or [ ];
    decls = c.decls or { };
    types = c.types or { };
    name = c.name or "<unnamed contribution>";
  };

  union =
    {
      contributions,
      strategies ? { },
    }:
    let
      cs = map normalise contributions;

      # ── THE LABEL REFUSALS, at the protocol boundary ──
      # A label names a DIMENSION, not a node. Two layers claiming one label is a genuine collision
      # with no order semantics to resolve it — unlike `decls`, where the ordered fold IS the
      # resolution — so it throws, and it names both contributors because "some layer" is not
      # actionable.
      labelled = prelude.concatMap (c: map (g: g // { contributor = c.name; }) c.edgeGraphs) cs;

      offendingReserved = prelude.filter (r: prelude.any (g: g.label == r.label) labelled) reserved;

      byLabel = builtins.groupBy (g: g.label) labelled;
      collidingLabels = prelude.filter (l: builtins.length byLabel.${l} > 1) (builtins.attrNames byLabel);

      contributorsOf = label: prelude.concatMapStringsSep ", " (g: g.contributor) byLabel.${label};

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
        else if collidingLabels != [ ] then
          throw "gen-assemble: ${
            prelude.concatMapStringsSep "; " (
              l: "the label `${l}` is claimed by more than one contribution (${contributorsOf l})"
            ) collidingLabels
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
  inherit union reserved normalise;
}
