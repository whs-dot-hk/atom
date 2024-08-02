let
  dev = import ./. {
    pub = {
      pins = import ./npins;
    };
  } ./dev;
in
dev.shell
