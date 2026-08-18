# gen-assemble — agent capability sheet

## Scope

The **shared framework toolkit**: the protocol a framework wraps around the one call that builds a
node set from many layers' contributions — the union, the identifier convention, and the structural
declarations the evaluator demands — held once here instead of rewritten by every framework.

**This repository is a SHELL. The library exports nothing.** `lib/default.nix` is `{ }`, and
`ci/tests/surface.nix` holds it there. The toolkit's constructs are specified and none is written,
because each is blocked on a named, open substrate defect and **two of the three fail silently**. The
specified construction refuses to evaluate by name while a precondition is unmet — and that refusal
is content. An export landed ahead of it would be a construct with no armed refusal behind it, which
is the one shape this design may not ship. **Read that as a fact about this repository, not as work
waiting to be picked up by whoever opens it.**

**Not in the hub roster.** `gen/lib/mkGenLibs.nix` has no `assemble` entry and gen-assemble has no
stratum. That is deliberate: the roster's stratum declaration is total and explicit by design — its
own text says "a member with no entry here is a build error, never a member of an implicit residue
bucket" — and the ruled timing is that **the entry lands with the first content migration, in the
same batch**, because content is what forces membership. Adding it now would land a member whose
surface is empty by construction. gen-memo, gen-vars and gen-rebuild each sat off the roster on the
same footing while empty. Consume via `inputs.gen-assemble.lib`, never through `mkGenLibs`.

## Not this library's job

Quoted text is the owner's own `flake.nix` `description` field, verbatim.

The whole risk of a shared toolkit is that it grows into the junk drawer every ecosystem gets, so
this table is the sheet's load-bearing half while the export surface is empty. The discriminator is
not taste — it is the membership criterion in the next section.

| Responsibility                                                                     | Owner                                                                                                                                                                                                                                                                                                                                                                                       |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Evaluating anything at all** — forcing a node, building the node set             | `gen-scope` — "gen-scope: demand-driven attribute grammar evaluator over algebraic scope graphs". The toolkit composes the argument to that call and never becomes the call. Limb 3 of the criterion is exactly this line                                                                                                                                                                   |
| **Identity minting** — deciding what a node IS                                     | `gen-schema` ("typed record registry with extension points for the pure-gen module system") and `gen-scope`. Identity has exactly ONE authority; a toolkit copy is a second one, which is why this is refused rather than merely absent. The toolkit's identifier convention is **addressing**, a different job — one spelling for one node, so two layers naming the same thing land on it |
| **The graph union operation itself**                                               | `gen-scope`, whose published `overlays` accessor is what the toolkit composes. The toolkit chooses when to call it and refuses reserved labels at its own boundary; the monoid is the substrate's                                                                                                                                                                                           |
| **The layered fold itself**                                                        | `gen-algebra` — "gen-algebra: pure Nix algebra — search monad, records, intensional functions, either". The ordered content fold is its `foldLayers` / `foldLayersTraced`; the toolkit supplies the ordered contribution list, never a second fold                                                                                                                                          |
| **Graph traversal, reachability, cycle detection**                                 | `gen-graph` — "gen-graph: accessor-based graph query combinators". Never re-implemented here                                                                                                                                                                                                                                                                                                |
| **The contribution DIMENSION** — a host graph, an env graph, an aspect graph       | The **caller**. A dimension is per-caller by construction; a canned host/env graph fails limb 1 and is refused. The three measured assemblies differ in kind here, not by a knob                                                                                                                                                                                                            |
| **The COMPUTATION over a dimension**                                               | The **caller**, for the same reason: three algorithms differing in kind means no framework writes *the same* one                                                                                                                                                                                                                                                                            |
| Stratified layered resolution of a settings value, schema validation, the ref scan | `gen-settings` — "gen-settings — stratified settings resolution as a pure layered fold, with refs-as-data, structured provenance, and the graduated injection construct". Its assembly-band content is destined here and **has not moved**; its schema validation and ref scan are destined for `gen-types` and the schema/identity libraries instead, and leave regardless of this library |
| Aspect-oriented composition and the aspect graph's facts                           | `gen-aspects` — "gen-aspects: aspect-oriented composition types (pure-gen, re-hosted on gen-merge)". It publishes facts and imports nothing; the toolkit is the *something* that calls the evaluator with them                                                                                                                                                                              |
| The module system's merge half                                                     | `gen-merge` — "gen-merge — pure-Nix byte-mode module MERGE engine (evalModuleTree) for the pure-gen module system". Whether its refusing merge transfers to the toolkit's label collision is an **open scan**, not a settled no                                                                                                                                                             |
| Cross-flake federation, origin-labelled subgraphs                                  | `gen-link` — "gen-link: cross-flake aspect federation over origin-labeled subgraphs". Origin distinguishes **flakes**; this library's contributors are layers sharing one origin, so that prior art is related in discipline and not in form                                                                                                                                                |
| General list/attr utilities                                                        | `gen-prelude` — "gen-prelude: vendored, nixpkgs-lib-free pure utilities for the gen ecosystem"                                                                                                                                                                                                                                                                                              |

### The membership criterion — the actual discriminator

A construct belongs to this toolkit **iff all three hold**:

1. **EVERY framework that assembles a graph must otherwise write it.**
2. **NOTHING IN THE SUBSTRATE IS DEFINED IN ITS TERMS** — the dependence runs one way, from this
   library down into the substrate and never back. This is a direction-of-dependence constraint, not
   "it exports no substrate vocabulary"; a library can satisfy the second while violating this one.
3. **It does not EVALUATE.**

Limb 2 has **no enforcement instrument today** — the direction-of-dependence lint is confirmed absent
with live controls — so it is checked by reading, over every member of the hub roster's `substrate`,
`modules` and `aspects` buckets. Do not read a green CI as evidence for it.

**The one construction error to avoid.** *A toolkit that reads the graph-shape half and the content
half as one operation has already failed.* Shape combines by a commutative, associative, idempotent
union and must not depend on arrival order; content arrives as an **ordered** contribution list and
folds by positional authority, with the order a parameter of the assembly and never derived from a
kind hierarchy. Merging the two is the design error this library exists to not make, and it is a
single-attrset-merge away at all times.

## Exports

**None.** `import ./lib` is `{ }`, and so is `inputs.gen-assemble.lib`.

Verify rather than trust:

```sh
nix eval --json --file lib --apply 'x: builtins.attrNames x'    # => []
```

Entry, once there is something to enter: `inputs.gen-assemble.lib` (flake) — `import ./lib`
(standalone). The root `default.nix` is the lib **value**, not a function, because gen-assemble
declares no inputs; gen-prelude and gen-algebra ship the same shape, and gen-memo shipped it while it
was a shell. When the toolkit acquires dependencies, `default.nix` becomes a function whose defaults
fetch the flake-locked revs, per the gen root-file convention.

`ci/tests/surface.nix` asserts the empty surface, so **the first export arrives as a failing test**.
That is the intended behaviour: it obliges the author to state the new surface here and in the
canonical reference in the same change, rather than widening the library silently.

## Entry points by task

While the surface is empty the tasks are about the repository, not the library.

| Task                                                                      | Reach for                                                                                                                                                                                            |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Run the suite                                                             | `nix flake check ./ci` — the command CI runs (`.github/workflows/ci.yml`, `working-directory: ci`)                                                                                                   |
| Run the suite as nix-unit, or one suite                                   | `nix-unit --flake ./ci#tests` · `nix-unit --flake ./ci#tests.purity`                                                                                                                                 |
| Get a shell with the locked nix-unit, plus `ci` / `fmt` / `repl` commands | `nix develop ./ci` (or `direnv allow` — `.envrc` is `use flake ./ci`)                                                                                                                                |
| Open the REPL                                                             | `nix repl --impure --file ci/repl.nix`                                                                                                                                                               |
| Format                                                                    | `cd ci && nix fmt -- --ci`                                                                                                                                                                           |
| Add the first export                                                      | Write it in `lib/`, then update `ci/tests/surface.nix`, this sheet's **Exports** section, and the canonical reference — the surface test fails until you do                                          |
| Land the hub roster entry                                                 | **With the first content migration, same batch** — two lines in `gen/lib/mkGenLibs.nix`: the binding and the `strata` entry. Never as a separate tidy-up                                             |
| Find what the toolkit's content is answerable to                          | The framework-toolkit library spec in the architecture papers repository — the membership criterion, the four refusals, the ordered-fold/commutative-union split, and the derived cost table         |
| Find the open preconditions blocking content                              | The three named substrate defects in the issue tracker: the structural partition that omits `imports`, the reserved-label discard at `buildNodes`, and the destroyed declaration-ordered vertex list |

## Measured traps

Every row was measured **in this repository, in this scaffolding run**, at the commit this sheet
ships in. Commands are given so each is re-runnable rather than trusted. Where a row contradicts a
sibling library's sheet, this one was re-measured here and the difference is stated.

| Trap                                                                                                                                                                                                                                                                                                                                            | Evidence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`AGENTS.md` and `.envrc` both match a GLOBAL gitignore** — a plain `git add` silently adds neither. `git add -f` is needed on the **first** add only; once tracked they stage normally                                                                                                                                                        | Hit live here: `git add .envrc …` aborted with *"The following paths are ignored by one of your .gitignore files: .envrc"* and staged nothing. `git check-ignore -v --no-index AGENTS.md .envrc README.md .gitignore` names `~/.config/git/ignore:22:/AGENTS.md` and `~/.config/git/ignore:18:.envrc`, and reports **nothing** for `README.md` / `.gitignore` — so the predicate discriminates rather than matching everything                                                                                  |
| **`git check-ignore` WITHOUT `--no-index` skips TRACKED paths**, so it goes quiet on exactly the file whose rule you just confirmed                                                                                                                                                                                                             | Measured here after `.envrc` was staged and `AGENTS.md` was not: `git check-ignore -v .envrc AGENTS.md` reports **only** `AGENTS.md`, exit 0. The same command with `--no-index` reports both. ★ Sibling sheets state this as "reports clean / exit 1"; that is the all-tracked case, and the discriminating form is the one above                                                                                                                                                                              |
| **nix-unit collects only cells named `test-*`. A cell that loses the prefix vanishes and the run reports GREEN** — the count moves 5/5 → 4/4 with no diagnostic anywhere                                                                                                                                                                        | Renaming `test-lib-exports-nothing` to `lib-exports-nothing` in `ci/tests/surface.nix` and re-running gave `🎉 4/4 successful`, exit **0**. Reconcile declared-vs-collected **both ways** rather than reading the count (command below)                                                                                                                                                                                                                                                                         |
| **An untracked file under `ci/tests/` is invisible to the flake — including a deliberately failing one.** New test files must be `git add`ed before any `nix` invocation, or the run is green about a tree that does not contain them                                                                                                           | A probe asserting `expr = 1; expected = 2;` was written to `ci/tests/staging.nix` and left untracked: `🎉 5/5 successful`, exit **0**. Positive control, same file, same run afterwards: `git add` it and the suite reports `😢 5/6`, exit **1**, naming `staging.test-untracked-file-is-invisible`. The green was invisibility, not absence                                                                                                                                                                    |
| **`nix flake check` and nix-unit are different oracles.** `checks.default` is a homegrown batch asserter that forces every `expr`; nix-unit's `expectedError` is unassertable — so a guard cannot be tested for its own firing, and no check whose failure cannot be observed belongs under `flake.tests`                                       | Both armed here. Setting `surface.test-lib-exports-nothing`'s expectation to `[ "sentinel" ]`: `nix flake check` (cwd `ci/`, the workflow's own command) exits **1** with `error: FAIL surface.test-lib-exports-nothing: got [], expected ["sentinel"]`; nix-unit exits **1** with `😢 4/5`. Both catch a wrong value; neither can assert that a *throw* happened. This matters more here than elsewhere: the toolkit's specified preconditions are **refusals**, and a refusal cannot be tested on this output |
| **A bare-leaf nix-unit target reports `0/0` — a false pass.** Establish a suite is non-vacuous before reading its green                                                                                                                                                                                                                         | This suite is **5 cells across 2 suites**, and the purity scan carries its own in-suite positive control (`test-forbidden-token-scan-is-live`, asserting the token predicate returns `[ "evalModules" ]` on a string that contains one) so its absence claim cannot pass by a dead predicate                                                                                                                                                                                                                    |
| **The purity scan reaches `lib/` — verified, not assumed.** An absence claim over source needs the scan armed, because an empty `lib/` or a broken `readDir` reports clean                                                                                                                                                                      | Injecting `let _sentinel = { lib }: lib.id; in` into `lib/default.nix` failed `purity.test-library-source-is-nixpkgs-lib-free`, naming both tokens: `[ "…/lib/default.nix: 'lib.'" "…/lib/default.nix: '{ lib }'" ]`. Reverted; the suite returns to 5/5                                                                                                                                                                                                                                                        |
| **The surface tripwire is armed, not decorative**                                                                                                                                                                                                                                                                                               | Changing `lib/default.nix` from `{ }` to `{ sentinel = true; }` failed `surface.test-lib-exports-nothing` in the same run in which the other four passed: `😢 4/5`. Reverted                                                                                                                                                                                                                                                                                                                                    |
| **The root flake has no `flake.lock`, and that is a consequence rather than an omission** — it declares zero inputs. `ci/flake.lock` is the only lock, and it is what the acceptance run uses                                                                                                                                                   | `flake.nix` has no `inputs` attribute; gen-prelude and gen-algebra are the same shape and likewise ship no root lock. Measured across the 20 roster members: the 18 that carry a root lock all declare inputs                                                                                                                                                                                                                                                                                                   |
| **`nix develop ./ci` WRITES to the working tree**: git-hooks-nix installs `.git/hooks/pre-commit` and generates `.pre-commit-config.yaml` at the repository root                                                                                                                                                                                | Observed on the first `nix develop ./ci` here: *"git-hooks.nix: updating …/gen-assemble repo"*, then *"pre-commit installed at .git/hooks/pre-commit"*. `.pre-commit-config.yaml` is in `.gitignore` for this reason — do not stage it, and do not read its appearance as an untracked-file surprise                                                                                                                                                                                                            |
| **The drift-check command carried by sibling sheets does not run.** `nix eval --json --expr 'builtins.attrNames (import ./lib)'` aborts in pure evaluation mode — a relative path in an `--expr` resolves to an absolute one, which pure mode forbids. A sheet's own verification command failing is the quiet version of an unverifiable claim | Measured here and, as a control, in a sibling: both abort with `error: access to absolute path '…/lib' is forbidden in pure evaluation mode`, and both answer `[]` under `--impure`. This sheet uses the `--file` form instead, which needs no `--impure`                                                                                                                                                                                                                                                       |
| **`nix fmt -- --ci` run from a LINKED WORKTREE formats the MAIN CHECKOUT and reports green about a tree it never touched** (treefmt resolves the tree root via `.git/config`, and a worktree's `.git` is a pointer *file*). Not triggered here — this is a normal checkout — but it will bite anyone who takes a worktree of this repo          | The shared CI module sets `projectRootFile = null` precisely to select treefmt's native `git rev-parse --show-toplevel` detection for this reason; its own comment records that `--tree-root` is rejected by the wrapper and `TREEFMT_TREE_ROOT_FILE` is ignored. Verify which tree was touched (`git status`) rather than reading the formatter's exit code                                                                                                                                                    |

## Theory

The toolkit claims **one** result, and claims it for the shape half only.

**Implements** *(claimed by this repository's design; no code yet realizes it — the claim is what the
first content is answerable to, and is recorded here so it cannot be quietly swapped)*

- **Mokhov 2017, *Algebraic Graphs with Class*** — the graph monoid: overlay is **commutative,
  associative and idempotent**, so combining contributed graph shape is order-independent, and the
  toolkit's union may not introduce an arrival-order dependence the operation does not have. The
  substrate's `overlays` accessor is the published site of that operation; this library composes it.

**Not a citation, and deliberately so: the CONTENT half.** `decls` and `types` arrive as an
**ordered contribution list** and fold by **positional authority** — a project ruling, not an
academic result, and the toolkit does not abort on two layers contributing content for one node. The
declared order is a **parameter of the assembly**, never derived from a global → class → host → user
kind hierarchy, which would re-import the topology the agnosticism law forbids. Recorded here beside
the citation precisely because the two halves obey opposite disciplines and a reader who takes
Mokhov as covering both will build the wrong thing.

**The cost is DERIVED, not measured.** The union is `foldl'` over list concatenation, so it is
**O(n·V + n·E)** in contributing layers and total vertices — degree 1 in each, which makes it linear
in `n` at fixed total `V` and quadratic when per-contribution size is held fixed instead. Every price
is paid **once at assembly and never per call**. Benchmarking at the thousands-of-hosts bar is owed
before any construct is written; no figure here is a measurement.

**Checked invariant.** `lib/` is free of the nixpkgs lib, enforced by `ci/tests/purity.nix` over
`lib/**.nix` + `flake.nix` + `default.nix`; nixpkgs enters only in `ci/` (the nix-unit harness and
treefmt). Armed in this run — see the traps table.

## Drift check

```sh
nix eval --json --file lib --apply 'x: builtins.attrNames x'
```

Current output (verbatim):

```json
[]
```

Reconcile the suite's declared cells against its collected ones, **both directions** — a `test-`
prefix lost in an edit reports green:

```sh
grep -rhoE '\btest-[a-z0-9-]+' ci/tests/ | sort > /tmp/declared
nix-unit --flake ./ci#tests | grep -oE 'test-[a-z0-9-]+' | sort > /tmp/collected
comm -23 /tmp/declared /tmp/collected   # declared but not collected — the silent-green case
comm -13 /tmp/declared /tmp/collected   # collected but not declared
```

Both are empty at this revision; the run is 5/5.

**Checks.** Test-runner invocation (from the repo root; CI runs the same command with
`working-directory: ci`):

```sh
nix flake check ./ci
```
