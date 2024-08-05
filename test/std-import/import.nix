let
  compose = set: (import ../../.) set ./import;
in
{
  default = compose { };
  noStd = compose { __features = [ ]; };
  explicit = compose { __features = [ "std" ]; };
  withNixpkgsLib = compose { __features = [ "pkg_lib" ]; };
}
