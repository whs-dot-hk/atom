let
  inherit (__internal) scope;
in
{
  Std = scope ? std;
  Lib = scope ? std && scope.std ? lib;
  Compose = atom.meta.features.compose;
  StdF = atom.meta.features.std;
}
