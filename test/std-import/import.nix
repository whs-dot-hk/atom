let
  compose = set: (import ../../.) set ./import;
in
{
  default = compose { };
  noStd = compose { config.std.use = false; };
  withNixpkgsLib = compose {
    config.std.nixpkgs_lib = true;
    config.std.use = true;
  };
  noStdNixpkgs = compose {
    config.std.nixpkgs_lib = true;
    config.std.use = false;
  };
}
