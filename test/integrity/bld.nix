let
  f = import ../../src/core/importAtom.nix;
  atom = f { } (
    # added to test implicit path conversion when path is a string
    builtins.toPath ./bld.atom
  );
in
builtins.deepSeq atom atom
