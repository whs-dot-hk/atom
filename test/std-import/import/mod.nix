let
  inherit (__internal) scope features;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  Core = features;
}
