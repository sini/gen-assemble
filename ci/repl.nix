# gen-assemble REPL — all exports in scope, plus the lib value itself as `genAssemble`.
#
# The library is a FUNCTION of its injected substrate, so this file has to resolve one before there
# is a value to splice. It resolves the acceptance run's own — this flake's `gen-scope` and the
# prelude and algebra beneath it — so what the REPL hands back is the surface the suite tests and
# not a second, differently-pinned one. That is also why it needs `--impure`.
let
  ci = builtins.getFlake (toString ./.);
  scope = ci.inputs.gen-scope.lib;
  prelude = ci.inputs.gen-scope.inputs.gen-prelude.lib;
  algebra = ci.inputs.gen-scope.inputs.gen-schema.inputs.gen-algebra.lib;

  genAssemble = import ../lib { inherit prelude scope algebra; };
in
{
  inherit
    genAssemble
    scope
    prelude
    algebra
    ;
}
// genAssemble
