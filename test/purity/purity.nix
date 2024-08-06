(import ../../compose.nix) {
  extern = {
    stdFilter = import ../../src/stdFilter.nix;
  };
} ./test
