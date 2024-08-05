let
  compose = set: (import ../../.) (set // { __internal__test = true; }) ./import;
in
{
  default = compose { };
  noStd = compose { __features = [ ]; };
  explicit = compose { __features = [ "std" ]; };
  withNixpkgsLib = compose { __features = [ "pkg_lib" ]; };
}
