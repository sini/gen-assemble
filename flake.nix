{
  description = "gen-assemble — the shared framework toolkit: the contribution protocol, its union, the id convention and the structural boilerplate that every framework assembling a node set otherwise writes for itself";

  # NO inputs. gen-assemble is a SHELL — the toolkit's content is specified but unwritten, so there
  # is nothing yet to declare a dependency for. The library's eventual shape takes its substrate
  # (the evaluator, the utility base) as INJECTED VALUES constructed inside the consumer's own eval,
  # so even when content lands the root input set is a decision the content makes, not one the
  # scaffold may make on its behalf. Declaring the evaluator now would additionally pin a substrate
  # whose three named preconditions are open, which the shell is explicitly built without presuming.
  # gen-prelude, gen-algebra and gen-memo-at-scaffold ship this same zero-input shape, so a
  # consumer's lock gains no transitive dependency by taking this input.
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
