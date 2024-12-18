let
  atom = import ./src/core/mod.nix;
  example = atom.importAtom { } ./example@.toml;
  # extern contains paths with .nix files excluded
  inherit (example.extern) source std-only list;
in
{
  # Show the filtered paths
  inherit source std-only list;
}
