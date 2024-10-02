let
  dev = (import ./src/core/importAtom.nix) { } (./. + "/src/dev@.toml");
in
dev.shell
