# Standalone (non-flake) entry. Flake consumers should use the `.lib` output.
#
# gen-assemble declares no inputs, so — as with gen-prelude, gen-algebra and gen-memo at its own
# scaffold — the standalone entry is the lib value itself rather than a function of its
# dependencies. When the toolkit acquires dependencies this file becomes a function whose defaults
# fetch the flake-locked revs, per the gen root-file convention.
import ./lib
