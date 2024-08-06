{
  # bar is a copy of it's parents private member foo
  Out = pre.bar == pre.pre.foo;

  # foo is private and should not be accesible from the top-level scope
  Fails = atom.foo;
}
