str:
let
  # strip off the first `/` of an absolute path
  frag = std.substring 1 (-1) str;
  # will fail if the string does not represent an absolute path
  # which is what we want since this function makes little sense otherwise
  validate = std.toPath str;
  # recombine the fragment string with an absolute path starting at the root
  # the result with be a path literal instead of a string
  path = /. + frag;
in
# avoid the extra work if it is already a path literal
if std.isPath str then str else std.seq validate path
