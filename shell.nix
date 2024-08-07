let
  dev = (import ./src/atom/fromManifest.nix) { } ./src/dev.toml;
in
dev.shell
