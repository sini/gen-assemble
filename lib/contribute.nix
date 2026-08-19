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
#
# ★ MEMBERSHIP IS DECLARED, AND IT IS ITS OWN HALF OF THE SHAPE. A contribution's `vertices` are the
# ids that layer declares to be members of the assembly, whether or not any relation holds of them.
# They combine by the same commutative union as every other piece of shape — one isolated vertex per
# id, overlaid — so the declared member set across contributions is a SET UNION with no ordering
# rule required.
#
# ★ AND `vertices` IS THE ONLY THING THAT DECLARES. EVERY ID A CONTRIBUTION NAMES — BOTH ENDPOINTS
# OF EVERY EDGE IT CARRIES, AND EVERY KEY OF ITS `decls` AND `types` — IS CHECKED AGAINST THE
# DECLARED MEMBER UNION AT THIS BOUNDARY, UNCONDITIONALLY. A node a contribution merely MENTIONS is
# not thereby a member, and the difference is invisible downstream — the constructor's node set
# absorbs an edge endpoint and a content key ALIKE, so an id nobody declared INVENTS that node and
# the assembly widens with nothing said. That is why a graph-borne vertex does not declare either:
# the same union puts it in the node set anyway, so reading it as a declaration would make this
# check agree with every edge it was written to refuse.
#
# ★ CONTENT KEYS ARE CHECKED ON THE MEASURED MECHANISM AND NOT BY ANALOGY WITH EDGES. A `decls` or
# `types` entry for an id no layer declared reaches the assembly AS A NODE — the constructor derives
# its node set from the content records as well as from the graph — so the two entrances are one
# defect, and covering only the relation channels would have closed one door onto a room with two.
#
# ★ THE ONE CHANNEL THIS DOES NOT CLOSE, STATED HERE BECAUSE AN UNQUALIFIED SAFETY CLAIM READS AS
# "NO ORACLE NEEDED": an ISOLATED VERTEX carried inside a contributed GRAPH. The scan ranges over a
# graph's EDGES, so a lone vertex overlaid into `parentGraph` or `importGraph` enters the node set
# with no layer declaring it and nothing said — measured green at this landing. Whether to close it
# is a live design question rather than a reading this construction may take on its own: `vertices`
# and a graph's vertex set would then be two spellings of one declaration, which is the collapse the
# paragraph above refuses.
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
  # `vertices` is the DECLARED-MEMBERSHIP CARRIER: the ids a contribution declares to be members of
  # the assembly, independent of any relation holding of them. It is a list of ids and not a graph
  # because membership is what a layer knows about itself — a layer enumerates what it brings, and
  # whether anything contains it is a separate declaration another layer may make.
  contributionKeys = [
    "name"
    "vertices"
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
      throw "gen-assemble: the contribution `${c.name}` offers ${builtins.toJSON unknown}, which this protocol does not carry. The record is total over ${builtins.toJSON contributionKeys}, and an unknown key is refused here rather than dropped, because a dropped key is a layer's content vanishing with nothing said."
    else
      {
        inherit (c) name;
        vertices = c.vertices or [ ];
        parentGraph = c.parentGraph or scope.empty;
        importGraph = c.importGraph or scope.empty;
        edgeGraphs = c.edgeGraphs or [ ];
        decls = c.decls or { };
        types = c.types or { };
      };

  # THE DECLARED MEMBER SET, CARRIED INTO THE SHAPE. One isolated vertex per declared id, overlaid —
  # so combining the declarations of several layers IS the graph monoid's own overlay, and the SET
  # UNION the protocol wants across contributions needs no rule of its own: overlay is commutative,
  # associative and idempotent, so which layer declared a member first is not observable and two
  # layers declaring one id declare one member. A member no relation contains is a root, which is
  # already what an isolated vertex means to the constructor.
  #
  # ★ THIS CARRIES MEMBERSHIP; THE REFUSAL BELOW CHECKS IT, AND THE TWO DIRECTIONS ARE NOT
  # SYMMETRIC. A declared id that no relation mentions is fine — that is a root, and enumerating
  # what a layer brings without relating it is what the key is for. An edge endpoint that no
  # contribution declared is refused.
  declaredMembers = c: scope.overlays (map scope.vertex c.vertices);

  # THE DECLARED MEMBER UNION AS A LOOKUP TABLE. Membership is a set question asked once per edge
  # endpoint, so the union is indexed rather than searched: scanning a list per endpoint would make
  # the check quadratic in the assembly, and the assemblies this protocol is sized for carry
  # thousands of nodes and thousands of edges.
  declaredIndex =
    cs:
    builtins.listToAttrs (
      prelude.concatMap (
        c:
        map (id: {
          name = id;
          value = true;
        }) c.vertices
      ) cs
    );

  # EVERY RELATION A CONTRIBUTION CARRIES, UNDER THE LABEL THE DIAGNOSTIC HAS TO NAME IT BY.
  # Containment and import travel as GRAPHS rather than as labels, but their edges are edges, and
  # the refusal ranges over an edge rather than over a label space — so they are named here by the
  # labels the substrate privileges them under, which is what a reader will find them by.
  relationsOf =
    c:
    [
      {
        label = "P";
        graph = c.parentGraph;
      }
      {
        label = "I";
        graph = c.importGraph;
      }
    ]
    ++ c.edgeGraphs;

  # THE UNDECLARED-ENDPOINT FACTS AS DATA, rendered by the refusal rather than computed inside it,
  # on the same ground as the collision facts below.
  #
  # ★ BOTH ENDPOINTS ARE READ, and that is the honest total form rather than a widening of a narrow
  # one. The hazard is usually stated of targets — an edge pointing at an id nobody declared invents
  # it — but an edge FROM an undeclared id invents it by the identical construction, since the node
  # set unions `from` and `to` alike. A check reading one side would leave the other silently open,
  # which is the same defect entered from the other end.
  #
  # ★ THE UNION IS GLOBAL AND THE ATTRIBUTION IS PER CONTRIBUTION. A cross-contribution reference is
  # legal — one layer declares a member, another relates it — so an endpoint is tested against what
  # EVERY layer declared, while the finding names the layer whose contribution carried the offending
  # edge, because that is the text that has to change.
  undeclaredEndpointsOf =
    cs:
    let
      declared = declaredIndex cs;
      undeclaredSide =
        c: r: side: id:
        prelude.optional (!(builtins.hasAttr id declared)) {
          contributor = c.name;
          inherit (r) label;
          inherit side id;
        };
    in
    prelude.unique (
      prelude.concatMap (
        c:
        prelude.concatMap (
          r:
          prelude.concatMap (
            e: undeclaredSide c r "from" e.from ++ undeclaredSide c r "to" e.to
          ) r.graph.edges
        ) (relationsOf c)
      ) cs
    );

  # THE CONTENT RECORDS, under the family name the diagnostic has to name them by. They are
  # enumerated rather than inlined for the reason `relationsOf` is: "the id is not declared" is not
  # actionable without the key a caller has to open to fix it, and a family read off a list is a
  # fact the finding carries rather than a string the message hard-codes twice.
  contentFamilies = [
    "decls"
    "types"
  ];

  # THE UNDECLARED-CONTENT-KEY FACTS AS DATA, on the construction the endpoint facts use and against
  # the same global index — rendered by the refusal rather than computed inside it.
  #
  # ★ THE UNION IS GLOBAL HERE TOO, AND FOR A REASON THIS HALF MAKES SHARPER. A layer supplying
  # content for a member another layer declared is not an edge case, it is the ordinary shape of a
  # layered assembly: a base enumerates the members and an override says something about them, which
  # is the case the ordered fold exists to settle. So a key is tested against what EVERY layer
  # declared, while the finding names the layer whose record carries it, because that is the text
  # that has to change.
  undeclaredContentKeysOf =
    cs:
    let
      declared = declaredIndex cs;
    in
    prelude.unique (
      prelude.concatMap (
        c:
        prelude.concatMap (
          family:
          prelude.concatMap (
            id:
            prelude.optional (!(builtins.hasAttr id declared)) {
              contributor = c.name;
              inherit family id;
            }
          ) (builtins.attrNames c.${family})
        ) contentFamilies
      ) cs
    );

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

  undeclaredEndpoints = contributions: undeclaredEndpointsOf (prelude.imap0 normalise contributions);

  undeclaredContentKeys =
    contributions: undeclaredContentKeysOf (prelude.imap0 normalise contributions);

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

      # ── THE DECLARED-MEMBERSHIP REFUSAL, at the protocol boundary ──
      # An id a contribution names that is not in the declared member union is refused by name: an
      # EDGE ENDPOINT, naming the contributing layer, the edge label and the missing id; and a
      # `decls` or `types` KEY, naming the contributing layer, the family and the missing id.
      #
      # ★ IT IS UNCONDITIONAL, AND IT IS UNCONDITIONAL BY CONSTRUCTION RATHER THAN BY DEFAULT. The
      # substrate's `strict` knob governs when the SUBSTRATE validates the containment relation;
      # this is the protocol's own boundary property, and a soundness refusal an evaluation-order
      # knob could switch off is the silence the refusal exists to close. `strict` never reaches
      # here — it is passed to the constructor, past this union — so there is no path by which it
      # could. The price is one eager pass over the merged edges, the same shape and cost as the
      # label check above.
      #
      # ★ AND THE GUARD BINDS THE WHOLE RESULT, not one key of it. Bound to `parentGraph` alone it
      # would be a property of which attribute a caller happens to read first, and a caller reading
      # only `decls` would receive a union built over edges naming nodes nobody declared.
      undeclared = undeclaredEndpointsOf cs;
      undeclaredContent = undeclaredContentKeysOf cs;

      # THE TWO CLASSES RENDER INTO ONE REFUSAL because they are one property with two entrances.
      # Both name an id no layer declared, both put that id into the assembly by the same union, and
      # both are discharged by the same two moves. Splitting them into two throws would make WHICH
      # diagnostic a caller receives a fact about which entrance their contribution used first.
      findings =
        map (
          f:
          "the contribution `${f.contributor}` carries an edge under the label `${f.label}` whose `${f.side}` endpoint `${f.id}` is not a declared member"
        ) undeclared
        ++ map (
          f:
          "the contribution `${f.contributor}` carries a `${f.family}` entry for `${f.id}`, which is not a declared member"
        ) undeclaredContent;

      requireDeclaredMembership =
        result:
        if findings == [ ] then
          result
        else
          throw "gen-assemble: ${prelude.concatStringsSep "; " findings}. Membership is DECLARED: a contribution's `vertices` is the only thing that DECLARES a node, and every id a contribution names — an edge endpoint, or a `decls`/`types` key — is checked against what every layer declared, because the node set absorbs them alike. So an id no layer declared is a node the contribution invents, admitted with nothing said. Declare the id in some contribution's `vertices` — any layer's will do, since one layer may relate, or say something about, what another declared — or drop the edge or entry that names it.";

      # SHAPE: commutative union. The result is a graph, and which layer went first is not
      # observable in the node set or the edge relations.
      shapeOf = f: scope.overlays (map f cs);
    in
    requireDeclaredMembership {
      # The declared members ride with containment, because that is the relation whose graph carries
      # the assembly's membership: a declared id with no parent edge is a root, and a declared id
      # another layer contains is the same node reached by both declarations. They LEAD their own
      # contribution's containment shape — the enumeration is the caller's own declaration, and the
      # vertex sequence is content that rides the declared order.
      parentGraph = shapeOf (
        c:
        scope.overlays [
          (declaredMembers c)
          c.parentGraph
        ]
      );
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
    undeclaredEndpoints
    undeclaredContentKeys
    ;
}
