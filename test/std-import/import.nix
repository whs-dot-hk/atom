let
  f = import ../../src/core/importAtom.nix { __internal__test = true; };
in
{
  default = f ./default.atom;
  noStd = f ./no-std.atom;
  explicit = f ./explicit.atom;
  withLib = f ./with-lib.atom;
}
