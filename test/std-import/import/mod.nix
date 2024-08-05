{
  Std = std ? set || abort "std missing";
  Lib = std ? lib || abort "lib missing";
}
