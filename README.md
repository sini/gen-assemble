# gen-assemble — the shared framework toolkit for the gen ecosystem

[![CI](https://github.com/sini/gen-assemble/actions/workflows/ci.yml/badge.svg)](https://github.com/sini/gen-assemble/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-pink?logo=github)](https://github.com/sponsors/sini)

A configuration framework that assembles one node set from many layers' contributions writes the
same protocol around the same call every time. What is genuinely per-framework is the contribution
**dimension** and the **computation** over it. What is duplicated is the **protocol around the
call** — the union, the identifier convention, and the structural declarations the evaluator
demands. gen-assemble holds the second, once, and never the first.

> **The library is a function of its substrate.** `import ./lib` and `inputs.gen-assemble.lib` both
> take `{ prelude, scope, algebra }` and return the toolkit's nine exports. gen-assemble declares no
> inputs of its own: the substrate arrives **injected** and is constructed inside the consumer's own
> evaluation. See [Status](#status--what-is-here-and-what-is-not).

## Table of Contents

- [Status](#status--what-is-here-and-what-is-not)
- [The membership criterion](#the-membership-criterion)
- [The name](#the-name)
- [Gen Ecosystem](#gen-ecosystem)
- [Design Principles](#design-principles)
- [Quick Start](#quick-start)
- [Testing](#testing)
- [Theoretical Foundations](#theoretical-foundations)

## Status — what is here, and what is not

**Here:** the contribution protocol and its union, the identifier convention, the structural
declarations, and the substrate precondition checks — nine exports, held to an exact list by a
surface tripwire that also binds the agent sheet's published surface to the library's real one. Plus
the purity invariant with its own positive control, and CI wired to the shared gen runner.

The three substrate defects this library was specified against have all landed, and **the refusal
they motivated is content that stayed**: `substratePreconditions` publishes the properties the
assembly depends on, and an assembly over a substrate failing any of them refuses to evaluate by
name, naming the record. Two of those three failed *silently* — a library that built green against
them would have handed a consumer a wrong answer with no diagnostic anywhere — which is why the
check is a construct rather than a note in a changelog, and why the suite arms it against a real
substrate pin on which it genuinely fails.

**In the hub roster, in the `framework` stratum**, landed with this content as the ruled timing
required: content is what forces membership, and the roster's stratum declaration is total by
design — a member with no entry there is a build error, never a member of an implicit residue
bucket. The binding is by construction, `import "${genInputs.gen-assemble}/lib" { … }` with the
substrate passed in, never a re-exported self-resolved `.lib`.

**Not here, and deliberately:**

- **Migrated content.** The assembly-band constructs that today live in
  [gen-settings](https://github.com/sini/gen-settings) — the batch-level knot-tying resolver, the
  cycle-message rendering, and the address rendering that travels with it — are destined here and
  none has moved. Each is its own sequenced piece of work, and the settings *feature's* integration
  sequences behind parity work while the assembly band does not.

## The membership criterion

Without one, a shared toolkit becomes the junk drawer every ecosystem grows. A construct belongs
here **iff all three hold**:

1. **Every framework that assembles a graph must otherwise write it.**
2. **Nothing in the substrate is defined in its terms** — the dependence runs one way, from this
   library down into the substrate and never back.
3. **It does not evaluate.**

| construct                                     | verdict    | why                                                                                                                |
| --------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------ |
| the contribution protocol and its union point | **admit**  | every assembling framework writes it; it composes the substrate's published accessors; nothing below names it      |
| the identifier convention                     | **admit**  | every assembling framework mints identifiers; the substrate defines *identity* and is not defined in terms of this |
| the structural declarations                   | **admit**  | the substrate's own classifier declares these the caller's obligation; the toolkit supplies bodies, never names    |
| identity minting                              | **refuse** | limb 2 — identity is substrate vocabulary with exactly **one** authority; a toolkit copy is a second one           |
| the evaluation (fold, closure, cascade)       | **refuse** | limbs 1 and 3 — three measured algorithms differing in kind, so no framework writes *the same* one                 |
| a canned host/env graph                       | **refuse** | limb 1 — a contribution dimension is per-caller by construction                                                    |
| schema validation and the ref scan            | **refuse** | limb 1 — these route to the type and schema libraries and leave regardless of this library                         |

Limb 2's enforcement instrument — a direction-of-dependence lint — **does not exist yet**, and is
recorded as confirmed absent with live controls. Until it lands, limb 2 is checked by reading. A
green CI is not evidence for it.

## The name

The library is named for its **contract** — what it is answerable for — rather than for its
mechanism: assembling one node set from many layers' contributions. The roster bucket it will join
uses the same verb: *a configuration framework assembles with this*.

The homonym sweep did **not** carry the ruling and is not presented as though it did. It found one
exported `assembl`-carrier in the whole ecosystem (`gen-settings.assembleHost`, itself retiring, and
retiring for its entity-kind-specific `Host` qualifier rather than for the verb), and it does not
discriminate this name from the rival it was run against. Contract-naming carried the ruling.

## Gen Ecosystem

| Library                                              | Role                                                                                                                                                       |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [gen-prelude](https://github.com/sini/gen-prelude)   | Pure nixpkgs-lib-free utility base                                                                                                                         |
| [gen-scope](https://github.com/sini/gen-scope)       | Demand-driven attribute grammar evaluator — **the sole evaluator**. The toolkit composes the argument to its node-building call and never becomes the call |
| [gen-algebra](https://github.com/sini/gen-algebra)   | Pure Nix algebra — home of the layered fold the ordered content half uses; never re-implemented here                                                       |
| [gen-graph](https://github.com/sini/gen-graph)       | Accessor-based graph query combinators — traversal, reachability, cycle detection                                                                          |
| [gen-schema](https://github.com/sini/gen-schema)     | Typed record registry — the identity authority the toolkit refuses to copy                                                                                 |
| [gen-aspects](https://github.com/sini/gen-aspects)   | Aspect-oriented composition types — publishes the aspect graph's facts and imports nothing                                                                 |
| [gen-settings](https://github.com/sini/gen-settings) | Stratified settings resolution — its assembly-band content is destined here; its validation and ref scan are not                                           |
| [gen-merge](https://github.com/sini/gen-merge)       | The module system's merge half — whether its refusing merge transfers here is an **open scan**, not a settled no                                           |
| [gen-link](https://github.com/sini/gen-link)         | Cross-flake federation over origin-labelled subgraphs — origin distinguishes *flakes*, so it is prior art in discipline, not in form                       |
| **gen-assemble**                                     | **This lib** — the shared framework toolkit (the protocol around the assembly call)                                                                        |

## Design Principles

- **The toolkit never evaluates.** It composes the argument to the evaluator's call. Evaluation
  belongs to the sole evaluator, and limb 3 of the membership criterion is exactly this line.
- **Shape and content obey opposite disciplines, and merging them is the design error.** Graph shape
  combines by a **commutative, associative, idempotent** union and must not depend on arrival order.
  Content arrives as an **ordered contribution list** and folds by **positional authority** — so two
  layers contributing content for one node are handed over in the declared order, not refused.
- **The declared order is a parameter of the assembly.** Never derived from a global → class → host
  → user kind hierarchy, which would re-import the topology the agnosticism law forbids.
- **A label collision IS refused, by name.** A label names a *dimension*, not a node, so two layers
  claiming one label is a genuine collision with no order semantics to resolve it. The refusal names
  both contributors — which is why a contribution's `name` is **required** rather than defaulted: a
  default turns "names both contributors" into a constant that names neither, and the property
  survives only if a contribution cannot exist without a name to be named by.
- **The contribution record is TOTAL, and an unknown key is refused at the constructor.** A protocol
  that reads the keys it knows and drops the rest cannot enforce the shape it publishes: a mistyped
  field, or one an earlier revision named, produces an empty result and a green evaluation. That is
  a layer's content vanishing with nothing said. The refusal is a property of the *constructor*, not
  of a later scan, so the contribution the protocol cannot honour never forms.
- **The identifier convention is addressing, not disambiguation.** One spelling for one node, so
  that two layers naming the same thing *land on it*. Node-identifier collision is not the failure
  mode: identity is content-independent, and co-contribution is what the ordered fold is for. An
  *empty half* is refused for the same reason a dropped key is: `":web1"` is a record that parses
  and addresses nothing.
- **Refuse to evaluate while a precondition is unmet.** Two of the three substrate defects this
  library was specified against failed silently, and a library that builds green on a substrate that
  will serve stale declarations is the exact shape the gate exists to stop. All three have landed;
  the check stayed, because what it asserts is a *property of the pinned substrate* and not a
  version.
- **Nothing is paid per call.** Every price the design carries is paid once, at assembly. That is
  what makes the toolkit cheaper than the hand-written sites it replaces rather than merely tidier.
- **nixpkgs-lib-free.** `lib/` depends on no nixpkgs lib; nixpkgs enters only in `ci/`, as the test
  harness and formatter. `ci/tests/purity.nix` pins this as a checked property with its own positive
  control.

## Quick Start

### As a flake input

```nix
{
  inputs.gen-assemble.url = "github:sini/gen-assemble";
  # gen-assemble declares no inputs — a consumer's lock gains no transitive dependency.
}
```

Then `gen-assemble.lib` is a **function** of the substrate:

```nix
genAssemble = inputs.gen-assemble.lib {
  scope = inputs.gen-scope.lib;
  prelude = inputs.gen-prelude.lib;
  algebra = inputs.gen-algebra.lib;
};

genAssemble.assemble {
  contributions = [
    {
      name = "hosts"; # required: every refusal this protocol makes is stated in it
      parentGraph = scope.edge "host:web1" "env:prod";
      decls."host:web1" = { tier = "base"; };
    }
  ];
}
```

### Standalone (non-flake)

```nix
let genAssemble = import (fetchTarball "https://github.com/sini/gen-assemble/archive/main.tar.gz");
in genAssemble { inherit prelude scope algebra; }
```

The standalone entry is the same **function** the flake output is. gen-assemble declares no inputs,
so there is nothing to fetch and nothing to pin: the substrate is injected and constructed inside the
consumer's own evaluation, which is what the gen↔gen boundary rule asks for.

## Testing

Three suites under `ci/`: `purity` (the nixpkgs-lib-free invariant over `lib/**.nix` + `flake.nix` +
`default.nix`, carrying its own positive control so the absence claim cannot pass by a dead
predicate), `surface` (the exact-list export tripwire, the standalone-entry/lib agreement, and the
binding between the library's real surface and the one `AGENTS.md` publishes), and `protocol` (the
acceptance surface for the contribution protocol, the identifier convention, the structural
declarations, and the precondition refusals).

```bash
nix flake check ./ci                     # what CI runs
nix-unit --flake ./ci#tests              # run everything
nix-unit --flake ./ci#tests.purity       # a single suite
```

The surface suite is a **tripwire, not a wall**: a new export fails it, and the author states the
new surface in `ci/tests/surface.nix`, in `AGENTS.md` and in the canonical reference in the same
change. The library cannot widen silently, and the sheet cannot fall behind it silently either.

**Every refusal in `protocol` is armed**, and armed the same way: the seeded defect fails in the same
run in which its clean arm passes, and each clean arm sits beside its seed rather than in another
suite. A refusal asserted with no firing seed is a cell that agrees with the defect it was written to
catch — including the precondition refusal, which is run against a real substrate pin on which it
genuinely fails rather than against a manufactured one.

`nix-unit` collects only cells named `test-*`; a cell that loses the prefix disappears and the run
still reports green. `AGENTS.md` carries the both-ways reconciliation command, and the rest of the
traps measured in this repository.

## Theoretical Foundations

- **Mokhov 2017, *[Algebraic Graphs with Class](https://dl.acm.org/doi/10.1145/3122955.3122956)*.**
  The graph monoid: overlay is commutative, associative and idempotent. That is what makes combining
  contributed graph **shape** order-independent, and it is the property the toolkit's union may not
  break. The substrate's published overlay accessor is the site of the operation; this library
  composes it rather than reimplementing it.

The **content** half claims no academic result and is stated here beside the citation for that
reason: it is an ordered fold by positional authority, a project ruling rather than a theorem, and a
reader who takes the monoid as covering both halves will build the wrong thing.

The shape half is realized by `lib/contribute.nix` — `union`'s `parentGraph`, `importGraph` and
label space overlay through the substrate's published accessor, and the suite asserts the
order-independence under *denotational* graph equality rather than a literal list compare, because
overlay concatenates and a literal compare would read `false` on a correct implementation. The
content half is realized beside it as the ordered fold, and the two are kept apart in the code for
the same reason they are kept apart here: a reader who takes the monoid as covering both will build
the wrong thing.
