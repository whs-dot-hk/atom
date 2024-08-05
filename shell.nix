let
  compose = import ./.;
  dev = compose {
    extern = rec {
      pins = import ./npins;
      pkgs = import pins.nixpkgs { };
    };
  } ./dev;
in
dev.shell
