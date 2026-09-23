# THE IDENTIFIER CONVENTION — `"<type>:<name>"`.
#
# Measured uniform across every site assembling the same KIND of graph, and re-invented at each of
# them. It is one line, and that is exactly why it belongs here: what a shared toolkit removes is
# not the hard part, it is the part that is written the same way three times and then drifts.
#
# ★ ITS JOB IS ADDRESSING, NOT DISAMBIGUATION, and the difference is load-bearing. Two layers naming
# `host:web1` are naming ONE node and must land on it — a node minted from the same kind and relata
# is one node with contributions from both, and how those contributions compose is what the ordered
# content fold settles. So this convention deliberately does NOT carry a contributor coordinate:
# adding one would separate what the fold exists to combine.
#
# Origin qualification is a different tool for a different problem. It distinguishes FLAKES — two
# federations' `apps/media/pg` are distinct nodes — while a toolkit's contributors are layers
# SHARING one origin, so an origin coordinate does not separate them and is not what is wanted here.
#
# ★ WHAT NEEDS NO COORDINATE IS THE IDENTIFIER; what needs a refusal is the LABEL; what needs an
# order is the CONTENT. Three questions, three different answers, and conflating them is how a
# union starts refusing the co-contribution it was built to allow.
{ prelude }:
let
  separator = ":";

  # ★ EACH DOOR REFUSES EXACTLY WHAT ITS BODY CANNOT TAKE, and names itself (ADR-0025 item 1). A
  # value that does not interpolate — a record, an integer, a list — used to reach the string
  # template and abort past `tryEval` naming nothing the caller wrote. The refusal names the TYPE and
  # never the value, because rendering a value that does not coerce is the very abort it replaces.
  # `mkId`/`idsOf` build by interpolation, which also takes a path and a record carrying
  # `__toString` or `outPath`; refusing those would narrow a door that answers on them today.
  # `parseId` reads with `builtins.split`, which takes a string and nothing else.
  interpolates =
    v:
    builtins.isString v || builtins.isPath v || (builtins.isAttrs v && (v ? __toString || v ? outPath));
  refuse =
    who: what: v:
    throw "gen-assemble.${who}: ${what} is a ${builtins.typeOf v}, expected a string";
  part =
    who: what: v:
    if interpolates v then v else refuse who what v;
in
{
  inherit separator;

  # `mkId "host" "web1"` ⇒ `"host:web1"`.
  mkId = type: name: "${part "mkId" "the type" type}${separator}${part "mkId" "the name" name}";

  # The inverse, for a consumer reading a node id back. Refuses by name rather than answering with a
  # plausible-looking half: a silent `null` here becomes a wrong lookup somewhere downstream.
  #
  # ★ AN EMPTY HALF IS A PLAUSIBLE-LOOKING HALF, which is why the separator being present is not on
  # its own enough to read an identifier back. `":web1"` parses to a node with no type and `"host:"`
  # to a type with no node under it; each is a well-formed-looking record that addresses nothing,
  # and handing one back is the answer this reader exists not to give. Both halves are therefore
  # required to be non-empty, and each is refused separately so the diagnostic says which one failed.
  parseId =
    id:
    let
      # `builtins.split` returns a list interleaved with match groups; the plain fields are the
      # string elements. The prelude carries no `splitString`, and wrapping one here would be this
      # library adding a utility rather than composing one.
      parts = builtins.filter builtins.isString (
        builtins.split separator (if builtins.isString id then id else refuse "parseId" "the identifier" id)
      );
      # Names may themselves contain the separator; only the FIRST field is the type.
      type = builtins.head parts;
      name = prelude.concatStringsSep separator (prelude.tail parts);
    in
    if builtins.length parts < 2 then
      throw "gen-assemble: `${id}` is not a conventional node identifier — the convention is `<type>${separator}<name>`, and a bare name has no type to read."
    else if type == "" then
      throw "gen-assemble: `${id}` is not a conventional node identifier — the convention is `<type>${separator}<name>`, and the type half is empty. An empty type addresses nothing while reading like a parse that succeeded."
    else if name == "" then
      throw "gen-assemble: `${id}` is not a conventional node identifier — the convention is `<type>${separator}<name>`, and the name half is empty. A type with no node under it addresses nothing while reading like a parse that succeeded."
    else
      {
        inherit type name;
      };

  # `idsOf "host" [ "web1" "db1" ]` ⇒ `[ "host:web1" "host:db1" ]`, order preserved because the
  # caller's order is a declaration and this is not the place to lose it.
  #
  # The arguments are checked WHOLE before the list is returned: a per-element guard leaves the list
  # lazy, so its refusal would reach only a caller that forces the element, and a caller reading the
  # length would be answered about a list that cannot be built. The type is checked once there is a
  # name to join it to; with none, the answer is `[ ]` whatever the type, as it is today.
  idsOf =
    type: names:
    builtins.seq (builtins.all (
      n: builtins.seq (part "idsOf" "the type" type) (builtins.seq (part "idsOf" "a name" n) true)
    ) names) (map (n: "${type}${separator}${n}") names);
}
