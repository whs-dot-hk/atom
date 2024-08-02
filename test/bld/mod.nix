{
  foo = 1;
  bar = atom.foo + 2;
  baz = self.bar + 4;
  test = std.set.filterMap;
  x = builtins.readFile "${self}/bum";
}
