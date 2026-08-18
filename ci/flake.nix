{
  inputs = {
    gen-harness.url = "github:sini/gen-harness";
    # nixpkgs is the CI runner's dependency (nix-unit harness, treefmt) and supplies the `lib` the
    # test modules use — including, here, to run the purity scan itself. It enters ONLY in ci/,
    # never as a `lib/` dep: the library (../lib) is nixpkgs-lib-free, which ci/tests/purity.nix
    # enforces. gen-assemble itself takes no inputs, so gen-harness and nixpkgs are the whole pin
    # set; every other runner input resolves through the harness's own pins.
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  outputs =
    inputs@{ gen-harness, ... }:
    let
      genAssemble = import ../lib;
    in
    gen-harness.lib.mkCi {
      inherit inputs;
      name = "gen-assemble";
      testModules = ./tests;
      specialArgs = { inherit genAssemble; };
    };
}
