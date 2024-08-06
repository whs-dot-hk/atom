let
  dev = (import ./.) { } ./dev.toml;
in
dev.shell
