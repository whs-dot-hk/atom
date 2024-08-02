f: set:
std.foldl' (
  acc: key:
  let
    val = f key set.${key};
  in
  if val == null || !std.isAttrs val then acc else acc // val
) { } (std.attrNames set)
