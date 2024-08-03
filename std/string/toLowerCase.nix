s:
let
  head = std.substring 0 1 s;
  tail = std.substring 1 (-1) s;
in
"${mod.toLower or mod.ToLower head}${tail}"
