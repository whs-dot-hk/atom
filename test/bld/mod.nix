{
  pub_foo = 1;
  bar = atom.foo + 2;
  baz = mod.bar + 4;
  pub_f = std.set.filterMap;
  pub_file = builtins.readFile "${mod}/bum";
  pub_buzz = mod.buzz;
  pub_next = ./next; # should be a non-existant path: /nix/store/next
  pub_bar = mod.bar;
}
