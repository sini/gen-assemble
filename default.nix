# Standalone (non-flake) entry. Flake consumers should use the `.lib` output.
#
# THREE CHANNELS, ONE PRECEDENCE, AND NONE OF THEM IS A PROBE. A named formal per dependency wins;
# the `inputs` bag is next, tested by attrset membership so a supplied-but-throwing value throws as
# ITSELF rather than falling back; the default is resolved from `./ci/flake.lock`, read as local
# data. There is NO `...`: an argument this root does not declare is a loud error, not a silent drop.
#
# THE PIN SOURCE IS THE ROOT `flake.lock`, NOT `ci/flake.lock` (owner-ruled Arm A, 2026-09-16:
# `den-hoag-4dfsv` §4.2). gen-assemble now declares all three dependencies as flake inputs, so a
# root lock exists and is what `import ./. { }` resolves through — the ci lock is the test graph's
# own pin source and is no longer read by this file.
#
# AND THE DEFAULTS BELOW STILL WALK PATHS, NOT NAMES — BUT THE TWO PATHS NO LONGER HAVE THE SAME
# SHAPE, AND THE ASYMMETRY IS THE STATEMENT. `gen-scope` is a direct root input; `prelude` and
# `algebra` are ALSO now direct root inputs (declared above). `prelude`'s default segment is left as
# the multi-hop path THROUGH gen-scope (`gen-scope>gen-prelude`) rather than repointed at the new
# direct edge — repointing would pin the same dependency twice under two different resolution rules
# for no discharge, and the two rules AGREE: the walk reaches node `gen-prelude_3` and the direct
# edge reaches node `gen-prelude`, at one and the same revision.
#
# `algebra`'s segment was `gen-scope>gen-schema>gen-algebra` on exactly that reasoning, AND THAT
# REASONING IS NOW VOID: gen-scope no longer declares a `gen-schema` input, so the route the
# trade-off preserved does not exist. There is no second resolution rule left to avoid — one live
# rule and one dead path — so `algebra` is repointed at its direct edge. The eager body below is
# what made that death loud rather than latent.
#
# The directly-declared `gen-prelude` root input still exists for a flake consumer applying this
# output by name (or an O4-shaped probe simulating one); this file's own standalone resolution never
# reads it.
#
# `src` AND `dep` ARE FORMALS, NOT `let` BINDINGS, AND THAT IS THE INJECTABLE RESOLVER SEAM. `src`
# is the only expression here that fetches; everything else reads the lock as data. A caller
# supplying `src = segs: throw "…"` therefore makes fetching IMPOSSIBLE for that application rather
# than merely absent. A `dep` bound in the `let` below would close over the `let`'s `src`, so the
# override would silently do nothing and the shim would fetch anyway, at rc 0.
#
# The `let` is OUTSIDE the lambda because a formal's default is evaluated in the FORMAL scope, which
# does not see a `let` in the body.
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  # A direct edge IS the node key; a `follows` value is a PATH resolved segment by segment from this
  # lock's own root. Never by indexing `lock.nodes.<label>` — a last-segment shortcut reads a
  # different node. IT TAKES ITS LOCK AS AN ARGUMENT SO THAT THE ENTRY CELL CAN DRIVE THIS EXACT
  # BINDING ON A FIXTURE WHERE THE TWO RULES DISAGREE BY CONSTRUCTION; a resolver closed over this
  # library's own lock could only ever be compared against a second copy of itself. This is the ONE
  # declaration of the rule in this library — `ci/tests/entry.nix` reads this binding through the
  # record the body hands `wire`, instead of transcribing the fold a second time.
  resolve =
    lock:
    let
      following =
        node: inp:
        let
          ins = lock.nodes.${node}.inputs or { };
          # A MISSING SEGMENT IS A THROW, NOT A DEFAULT — the `or { }` above guards the node's
          # `inputs` ATTRIBUTE and never the segment lookup, and making the lookup total would turn a
          # dead path into a silent wrong answer at a consumer instead of a refusal here. The message
          # names BOTH ENDS because the builtin's own names only one: a segment that stopped
          # resolving says nothing about which node stopped carrying it.
          v =
            if ins ? ${inp} then
              ins.${inp}
            else
              throw "gen-assemble: lock path segment '${inp}' is not an input of node '${node}'";
        in
        if builtins.isString v then v else builtins.foldl' following lock.root v;
    in
    segs: builtins.foldl' following lock.root segs;
  fetch = resolve lock;
in
{
  inputs ? { },
  src ? segs: "${builtins.fetchTree lock.nodes.${fetch segs}.locked}",
  # Arity dispatch, because a dependency's root is a function at a shim'd library and a bare value
  # at a leaf, and neither `import p` nor `import p { }` is total over both.
  dep ?
    segs:
    let
      v = import (src segs);
    in
    if builtins.isFunction v then v { } else v,
  # `wire` IS THE THIRD SEAM, AND IT IS THE ONE CHANNEL BY WHICH THIS FILE PUBLISHES ANYTHING. Nix
  # publishes WHETHER a formal has a default and never WHAT it is, and a formal is an INPUT channel
  # that cannot carry a value outward — so the only place a formal NAME and its resolved PATH are
  # both in scope is this file's argument TO `wire`, not `./lib`, and `resolve` rides out on that
  # same argument rather than on a fourth formal. `wire` RECEIVES `{ deps, resolve }`, and `./lib`
  # sees only whatever `wire` chooses to hand it — here, the default
  # `{ deps, resolve }: import ./lib deps,`, which is the only thing that makes `deps` and `./lib`'s
  # argument coincide. A cell injecting `dep = segs: segs` alongside `wire = args: args` reads this
  # shim's own formal-to-path map AND its own resolver straight off, with nothing fetched, no path
  # restated and no fold transcribed. The record destructures with no `...`, so a drifted body shape
  # is loud at the default; adding `wire` was a widening and broke no caller for the same reason —
  # there is no `...` here, and no caller passes a name this root does not declare.
  wire ? { deps, resolve }: import ./lib deps,
  prelude ?
    inputs.gen-prelude or (dep [
      "gen-scope"
      "gen-prelude"
    ]),
  scope ? inputs.gen-scope or (dep [ "gen-scope" ]),
  algebra ? inputs.gen-algebra or (dep [ "gen-algebra" ]),
}:
# THE BODY IS EAGER, AND THAT IS WHAT MAKES THE ENTRY CELL TOTAL RATHER THAN PARTIAL. `forced` forces
# every wired dependency to WHNF before `./lib` sees it, so a default that cannot resolve is loud AT
# THE BOUNDARY rather than wherever a consumer first reaches an attribute. Without it a force of this
# root reaches only the dependencies the published surface happens to be derived from — and
# `builtins.deepSeq` cannot make up the difference, because it does not enter a lambda. Measured at
# this library: a pure force of the landed body reached 1 of its 3 dependency paths, the one its
# `substratePreconditions` value happens to be derived from, and read green over the other two. With
# the eager body a WHNF force of the root reaches all three, whatever the published surface's shape.
#
# THE FORCE STOPS AT WHNF DELIBERATELY: `builtins.seq` of an attrset does not force its members, so
# this reaches each dependency's root VALUE and never a member of it. A library that deliberately
# refuses to build some member is therefore not an exception to it.
let
  deps = { inherit prelude scope algebra; };
  forced = builtins.deepSeq (builtins.mapAttrs (_: builtins.typeOf) deps) null;
in
builtins.seq forced (wire {
  inherit deps resolve;
})
