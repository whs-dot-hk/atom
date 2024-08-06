/**
  Parse a string into a name and extension.

  # Examples

  ```nix
  parse "foo.bar" => { name = "foo"; ext = "bar"; }
  parse "invalid" => null
  ```

  # Type

  ```
  parse :: String -> AttrSet | Null
  ```

  # Parameters

  - `str`: The string to parse.

  # Return Value

  An attribute set with `name` and `ext` attributes, or `null` if the string cannot be parsed.
*/

str:
let
  r = std.match "([^.]+)\\.(.+)" (baseNameOf str);
in
if r == null || std.length r < 2 then
  null
else
  {
    name = std.head r;
    ext = std.elemAt r 1;
  }
