{
  description = "gen-assemble — the shared framework toolkit: the contribution protocol, its union, the id convention and the structural boilerplate that every framework assembling a node set otherwise writes for itself";

  # NO inputs, and that is what the content decided rather than what the scaffold left undone. The
  # library takes its substrate — the evaluator, the utility base, the record algebra — as INJECTED
  # VALUES constructed inside the consumer's own evaluation, which is the gen↔gen boundary rule's
  # shape: only plain data crosses, and a library that re-declared the evaluator here would pin a
  # substrate on its consumer's behalf. gen-prelude and gen-algebra ship this same zero-input shape,
  # so a consumer's lock gains no transitive dependency by taking this input.
  #
  # A consequence, not an omission: zero inputs means no root lock file. The only lock in this
  # repository is ./ci/flake.lock, and it is what the acceptance run uses.
  #
  # The test runner lives in ./ci, which is a separate flake.
  outputs =
    { ... }:
    {
      lib = import ./lib;
    };
}
