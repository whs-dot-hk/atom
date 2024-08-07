/**
  Convert a string to a path.

  # Examples

  ```
  strToPath "/foo/bar" => /foo/bar
  strToPath "/home/foo" => /home/foo
  ```

  # Type

  ```
  strToPath :: String -> Path
  ```

  # Parameters

  - `str`: The string to convert.

  # Return Value

  A path corresponding to the input string.
*/
str:
let
  validate = std.toPath str;
  path = /. + str;
in
if std.isPath str then str else std.seq validate path
