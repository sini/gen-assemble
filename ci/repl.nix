# gen-assemble REPL — all exports in scope, plus the lib value itself as `genAssemble`.
#
# The shell exports nothing yet, so the splice contributes no bindings and `genAssemble` is `{ }`;
# both stay correct as the surface fills in.
let
  genAssemble = import ../lib;
in
{
  inherit genAssemble;
}
// genAssemble
