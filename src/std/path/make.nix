/**
  Create a path by combining a base path and a string.

  # Examples

  ```nix
  path.make /. "foo/bar" => /foo/bar
  path.make ./. "foo/bar" => /current/directory/foo/bar
  path.make /foo "bar/baz" => /foo/bar/baz
  path.make /foo "/bar/baz" => /foo/bar/baz
  ```

  # Type

  ```
  path.make :: Path -> String -> Path
  ```

  # Parameters

  - `base`: The base path. Use `/.` for absolute paths from root, `./.` for paths relative to the current directory, or any other path for custom base directories.
  - `str`: The string to combine with the base path.

  # Return Value

  A path combining the base path and the input string.
*/
abs: frag:
let
  s = x: builtins.isString x || builtins.isPath x || x ? outPath || x ? __toString;
  abs' = if builtins.isPath abs then abs else /. + abs;
  p = builtins.substring 0 1 frag;

  f =
    if !(s abs && s frag && !builtins.isPath frag) then
      throw ''
        in std.path.make:

               expected:
                 - abs: absolute path
                 - frag: string

               got:
                 - abs: ${builtins.typeOf abs}
                 - frag: ${builtins.typeOf frag}
      ''
    else if p != "/" then
      abs' + "/${frag}"
    else
      abs' + frag;
in
builtins.addErrorContext "in call to std.path.make" f
