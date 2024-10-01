let
  dev = (import ./src/core/importAtom.nix) { } ./src/dev.atom;
in
dev.shell
