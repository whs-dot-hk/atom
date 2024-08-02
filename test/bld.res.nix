{
  bar = 3;
  baz = 7;
  buzz = {
    bar = 3;
    baz = 7;
    foo = 1;
    fuzz = {
      bar = 5;
      baz = 9;
      foo = 1;
      next = {
        g = 5;
        h = 8;
      };
      wuzz = {
        bar = 7;
        baz = 11;
        cuzz = {
          bar = 3;
          baz = 7;
          foo = 1;
          next = {
            g = 5;
            h = 8;
          };
        };
        foo = 1;
        next = {
          g = 5;
          h = 8;
        };
      };
    };
    next = {
      g = 5;
      h = 8;
    };
  };
  foo = 1;
  next = {
    g = 5;
    h = 8;
  };
  test = scopedImport {std = builtins;} "${../std/set/filterMap.nix}";
  x = builtins.readFile ./bld/bum;
}
