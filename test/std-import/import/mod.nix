let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  CoreF = __atom.features.resolved.core;
  StdF = __atom.features.resolved.std;
  Sanity = scope.std.__internal.__isStd__;
}
