# THE ACCEPTANCE SURFACE for the contribution protocol.
#
# Every refusal here is ARMED: the seeded defect fails in the same run in which the clean arm passes,
# and each clean arm is stated beside its seed rather than in another suite. A refusal asserted
# without a firing seed is a cell that agrees with the defect it was written to catch.
{
  genAssemble,
  genAssembleUnmet,
  scope,
  ...
}:
let
  inherit (genAssemble)
    union
    assemble
    mkId
    structuralDecls
    ;

  # Two layers, each contributing shape, a labelled dimension and content for the SAME node — which
  # is the case the protocol exists for: co-contribution settled by position, not refused.
  base = {
    name = "base";
    parentGraph = scope.edge (mkId "host" "web1") (mkId "env" "prod");
    edgeGraphs = [
      {
        label = "M";
        graph = scope.edge (mkId "host" "web1") (mkId "group" "www");
      }
    ];
    decls = {
      ${mkId "host" "web1"} = {
        tier = "base";
        region = "eu";
      };
    };
    types = {
      ${mkId "host" "web1"} = "host";
    };
  };
  override = {
    name = "override";
    parentGraph = scope.edge (mkId "host" "db1") (mkId "env" "prod");
    edgeGraphs = [
      {
        label = "R";
        graph = scope.edge (mkId "host" "db1") (mkId "role" "primary");
      }
    ];
    decls = {
      ${mkId "host" "web1"} = {
        tier = "override";
      };
    };
  };

  merged = union {
    contributions = [
      base
      override
    ];
  };
  reversed = union {
    contributions = [
      override
      base
    ];
  };

  built = assemble {
    contributions = [
      base
      override
    ];
  };
  builtReversed = assemble {
    contributions = [
      override
      base
    ];
  };

  # Denotational graph equality: `overlay` concatenates, so Mokhov's axioms hold up to the graph's
  # denotation and a LITERAL list comparison fails on a correct implementation.
  asSets = g: {
    vertices = builtins.sort builtins.lessThan (
      builtins.attrNames (builtins.groupBy (v: v) g.vertices)
    );
    edges = builtins.sort builtins.lessThan (map (e: "${e.from}->${e.to}") g.edges);
  };

  throws = e: !(builtins.tryEval (builtins.deepSeq e 1)).success;
in
{
  flake.tests.protocol = {
    # ── The content fold RESPECTS the declared order ──
    # Two layers name one node; the later one wins per field, and nothing is refused.
    test-content-follows-the-declared-order = {
      expr = merged.decls.${mkId "host" "web1"};
      expected = {
        tier = "override";
        region = "eu";
      };
    };
    # ARMED: reversing the list must move the answer. Without this the cell above passes on a fold
    # that ignores order entirely.
    test-seed-reversing-the-list-moves-the-content = {
      expr = reversed.decls.${mkId "host" "web1"};
      expected = {
        tier = "base";
        region = "eu";
      };
    };

    # ── The SHAPE union is order-INdependent, asserted at the merged contribution ──
    # Under denotational equality, because the representation concatenates.
    test-shape-is-order-independent-at-the-merged-contribution = {
      expr = asSets merged.parentGraph == asSets reversed.parentGraph;
      expected = true;
    };
    # ARMED: the predicate can tell graphs apart, so the identity above is not a comparison that
    # could not have failed.
    test-seed-a-different-graph-is-not-equal-under-the-same-predicate = {
      expr = asSets merged.parentGraph == asSets (scope.edge "x" "y");
      expected = false;
    };

    # ── AND THE NODE SET IS ORDER-INDEPENDENT TOO, which is now observable ──
    # This assertion was deferred while the constructor destroyed the declared vertex order: it
    # alphabetised the node set whatever the union did, so a commutative union and an
    # order-destroying one produced identical output and the cell could not fail. The order now
    # survives, so the two halves separate: the SET is invariant, the SEQUENCE is not.
    test-the-node-set-is-invariant-under-contribution-order = {
      expr = builtins.attrNames built.nodes == builtins.attrNames builtReversed.nodes;
      expected = true;
    };
    test-the-vertex-sequence-is-not-invariant-because-it-is-content = {
      expr = built.nodeOrder == builtReversed.nodeOrder;
      expected = false;
    };

    # ── The label refusals, both armed ──
    test-a-reserved-label-is-refused = {
      expr = throws (union {
        contributions = [
          base
          (
            override
            // {
              edgeGraphs = [
                {
                  label = "P";
                  graph = scope.edge "a" "b";
                }
              ];
            }
          )
        ];
      });
      expected = true;
    };
    test-a-duplicate-label-is-refused = {
      expr = throws (union {
        contributions = [
          base
          (override // { inherit (base) edgeGraphs; })
        ];
      });
      expected = true;
    };
    # CONTROL for both: an ordinary, distinct label passes in the same run.
    test-control-distinct-ordinary-labels-pass = {
      expr =
        builtins.length
          (union {
            contributions = [
              base
              override
            ];
          }).edgeGraphs;
      expected = 2;
    };

    # ── The identifier convention addresses rather than disambiguates ──
    # Two layers naming one node land on it: one node, contributions from both.
    test-two-layers-naming-one-node-co-contribute = {
      expr = builtins.length (
        builtins.filter (id: id == mkId "host" "web1") (builtins.attrNames built.nodes)
      );
      expected = 1;
    };
    test-parseId-refuses-a-bare-name = {
      expr = throws (genAssemble.parseId "web1");
      expected = true;
    };
    test-control-parseId-reads-a-conventional-id = {
      expr = genAssemble.parseId (mkId "host" "web1");
      expected = {
        type = "host";
        name = "web1";
      };
    };

    # ── The structural boilerplate is supplied under the names the evaluator READS ──
    test-structural-decls-carry-the-read-names = {
      expr = builtins.attrNames (structuralDecls built.nodes);
      expected = [
        "children"
        "imports"
      ];
    };
    # And the child relation answers, over the assembled node set.
    test-children-answers-over-the-assembled-nodes = {
      expr = builtins.attrNames ((structuralDecls built.nodes).children null (mkId "env" "prod"));
      expected = [
        (mkId "host" "db1")
        (mkId "host" "web1")
      ];
    };

    # ── The precondition refusal, ARMED against a real unmet pin ──
    # `genAssembleUnmet` is this library over a substrate pinned one commit before the declared
    # vertex order landed. Without an arm that genuinely fails, a green precondition oracle tells a
    # consumer nothing.
    test-an-unmet-substrate-is-refused-by-name = {
      expr = throws (genAssembleUnmet.assemble { contributions = [ base ]; });
      expected = true;
    };
    test-control-the-met-substrate-assembles = {
      expr = builtins.isAttrs built.nodes;
      expected = true;
    };
    # The refusal names WHICH properties failed, so a consumer knows which pin to move — and the
    # list is exact rather than a count, because a count cannot tell one failing property from
    # another and this cell exists to say which.
    test-the-unmet-substrate-names-the-failing-properties = {
      expr = map (c: c.record) (builtins.filter (c: !c.met) genAssembleUnmet.substratePreconditions);
      expected = [ "den-hoag-u1sf" ];
    };
    # ★ And the checks that pin cannot ANSWER are not reported as failures. On that substrate the
    # other two properties were in fact repaired; probing them through a constructor that is not
    # there would report two live defects that are not live, so the entry check gates them and the
    # reading is the entry alone.
    test-an-unevaluable-probe-is-not-reported-as-a-failing-property = {
      expr = map (c: c.record) genAssembleUnmet.substratePreconditions;
      expected = [ "den-hoag-u1sf" ];
    };
    # CONTROL: on the met substrate all four are read and all four hold.
    test-control-the-met-substrate-reads-every-check = {
      expr = map (c: c.record) genAssemble.substratePreconditions;
      expected = [
        "den-hoag-u1sf"
        "den-hoag-aznm"
        "den-hoag-r9ne"
        "den-hoag-u1sf"
      ];
    };
    test-control-the-met-substrate-has-no-unmet-precondition = {
      expr = builtins.filter (c: !c.met) genAssemble.substratePreconditions;
      expected = [ ];
    };

    # ── ADR-0014: no flat name means two different things ──
    test-no-flat-name-collides-with-the-substrate = {
      expr = builtins.filter (n: builtins.elem n (builtins.attrNames scope)) (
        builtins.attrNames genAssemble
      );
      expected = [ ];
    };
    # ARMED: the predicate finds a collision when there is one — `children` is published by the
    # substrate and would collide if the boilerplate were exported flat.
    test-seed-the-collision-predicate-fires-on-a-known-shared-name = {
      expr = builtins.elem "children" (builtins.attrNames scope);
      expected = true;
    };
  };
}
