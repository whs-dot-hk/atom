let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  Compose = __atom.features.resolved.compose;
  StdF = __atom.features.resolved.std;
  Sanity = scope.std.__internal.__isStd__;
}
