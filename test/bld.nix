let
  mod = import ../. { } ./bld;
in
builtins.deepSeq mod mod
