let
  f = import ../../src/atom/fromManifest.nix { __internal__test = true; };
in
{
  recursive-features = f ./recursive-features.toml;
}
