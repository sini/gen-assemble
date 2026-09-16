{
  description = "gen-assemble — the shared framework toolkit: the contribution protocol, its union, the id convention and the structural boilerplate that every framework assembling a node set otherwise writes for itself";

  # DECLARED, NOT APPLIED (owner-ruled Arm A, 2026-09-16: `den-hoag-4dfsv` §4.2). The library still
  # takes its substrate — the evaluator, the utility base, the record algebra — as INJECTED VALUES
  # constructed inside the consumer's own evaluation, which is the gen↔gen boundary rule's shape:
  # only plain data crosses. What changes is which artefact this flake's OWN pin source is: all
  # three dependencies — `gen-scope`, `gen-prelude`, `gen-algebra` — are now declared root inputs,
  # so `nix flake lock` has a root lock to write and the standalone entry (`default.nix`) has a pin
  # source that is not `ci/flake.lock` — ADR-0037's amendment forecloses staying there. Declaring is
  # not applying: the ruling's ground is that all three ADR-0037-open members already publish their
  # root UNAPPLIED, so a declared input is read by nothing but `nix flake lock` — no substrate is
  # pinned on a consumer's behalf, and gen-prelude, gen-algebra, gen-delivery and gen-program still
  # ship the SAME unapplied-output shape this member does.
  #
  # The test runner lives in ./ci, which is a separate flake.
  #
  # ★ THE FLAKE OUTPUT IS THE ROOT, PUBLISHED UNAPPLIED. `./.` and `./lib` were two independent
  # constructions of one value and so free to disagree; there is ONE construction site now, and the
  # two entry paths differ only in who supplies the arguments. Publishing the root unapplied is what
  # lets the consumer supply every argument rather than dropping the edge through to this
  # repository's own root lock on the flake path.
  inputs = {
    gen-scope.url = "github:sini/gen-scope";
    gen-prelude.url = "github:sini/gen-prelude";
    gen-algebra.url = "github:sini/gen-algebra";
  };

  outputs = _: {
    lib = import ./.;
  };
}
