let
  dev = import ./. {
    extern = {
      pins = import ./npins;
    };
  } ./dev;
in
dev.shell
