let
  compose = set: (import ../../.) (set // { __internal__test = true; }) ./import;
in
{
  default = compose { };
  noStd = compose { composeFeatures = [ ]; };
  explicit = compose { stdFeatures = [ ]; };
  # withNixpkgsLib = compose { stdFeatures = [ "pkg_lib" ]; };
}
