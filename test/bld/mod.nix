{
  foo = 1;
  bar = atom.foo + 2;
  baz = mod.bar + 4;
  test = std.set.filterMap;
  x = builtins.readFile "${mod}/bum";
}
