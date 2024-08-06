let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  Compose = __atom.features.parsed.compose;
  StdF = __atom.features.parsed.std;
  Sanity = scope.std.__internal.__isStd__;
}
