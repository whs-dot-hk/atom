let
  f = import ../../src/core/importAtom.nix { __internal__test = true; };
in
{
  recursive-features = f ./recursive-features.atom;
  recursive-features-loop = f ./recursive-features-loop.atom;
}
