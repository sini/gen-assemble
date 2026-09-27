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
    # P1 (den-hoag-7gp66) moved the guard from the native formal into an explicit
    # `checkOptions`/`checkRequired` binding in the door body, so the export is now a bare
    # positional `args:` and `functionArgs` on it is empty by construction. A regression back to a
    # native closed formal — the shape that aborted past `tryEval` — would show up here as a
    # non-empty record; the "still refuses catchably" half is `ci/tests/door-checks.nix`'s job.
    test-assemble-has-no-native-closed-formal = {
      expr = builtins.functionArgs genAssemble.assemble;
      expected = { };
    };
  };
}
