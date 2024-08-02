s:
let
  r = std.match "([^.]+)\\.(.+)" s;
in
if r == null || std.length r < 2 then
  null
else
  {
    name = std.head r;
    ext = std.elemAt r 1;
  }
