/**
  Parse a string into a name and extension.

  # Examples

  ```nix
  parse "foo.bar" => { name = "foo"; ext = "bar"; }
  parse "invalid" => null
  ```

  # Type

  ```
  parse :: String -> AttrSet
  ```

  # Parameters

  - `str`: The string to parse.

  # Return Value

  An attribute set with the file `name` and an optional `ext` attribute representing the extension, if one exists.
*/

str:
let
  s = x: builtins.isString x || builtins.isPath x || x ? outPath || x ? __toString;
  l = builtins.length r;
  r = builtins.match "(\\.*[^.]+)\\.?(.+)?" (baseNameOf str);

  isnt = !s str;

  name = builtins.head r;
  ext = builtins.elemAt r 1;
  f =
    if isnt || r == null then
      throw ''
        in std.file.parse:

               expected:
                 - str: path or string representing a file name

               got:
                 - str: ${if isnt then "a ${builtins.typeOf str}" else str}
      ''
    else if l >= 2 && ext != null then
      { inherit name ext; }
    else
      { inherit name; };
in
builtins.addErrorContext "in call to std.file.parse" f
