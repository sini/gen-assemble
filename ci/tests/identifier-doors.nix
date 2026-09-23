# THE IDENTIFIER DOORS' ADMITTING HALF (den-hoag-bkdkg). The refusals are message cells in
# `ci/tests-error.nix`; these are what each door still answers, so a guard that refused more than
# its body cannot take goes red here rather than narrowing a door silently. Interpolation takes a
# record carrying `__toString`, and `idsOf` over no names answers `[ ]` whatever the type — both
# answered before the guards landed, and both still must.
{ genAssemble, ... }:
{
  flake.tests.identifierDoors = {
    test-mkId-admits-a-string-pair = {
      expr = genAssemble.mkId "host" "web1";
      expected = "host:web1";
    };
    test-mkId-admits-what-interpolates = {
      expr = genAssemble.mkId "host" { __toString = _: "web1"; };
      expected = "host:web1";
    };
    test-idsOf-over-no-names-reads-no-type = {
      expr = genAssemble.idsOf { name = "a"; } [ ];
      expected = [ ];
    };
    test-idsOf-admits-string-names = {
      expr = genAssemble.idsOf "host" [
        "web1"
        "db1"
      ];
      expected = [
        "host:web1"
        "host:db1"
      ];
    };
    test-parseId-admits-an-identifier = {
      expr = genAssemble.parseId "host:web1";
      expected = {
        type = "host";
        name = "web1";
      };
    };
    # The guards live in the door bodies, never in a wrapper at the export, and a wrapper is
    # detectable: it erases the formals a caller reads. `assemble` is the export that has formals.
    test-assemble-keeps-its-published-formals = {
      expr = builtins.functionArgs genAssemble.assemble;
      expected = {
        contributions = false;
        kinds = true;
        strategies = true;
        strict = true;
      };
    };
  };
}
