/**
  # `compose`

  ## Function

  Atom's composer demonstrates a module system for Nix.

  It searches from a passed root directory for other dirs containing a `mod.nix` file.
  It's terminating condition is when a `mod.nix` does not exist. Leaving directories without
  one unexplored.

  Along the way it auto-imports any other Nix files in the same directory as `mod.nix` as module
  members. Crucially, every imported file is called with `scopedImport` provding a well defined
  global scope for every module: `mod`, `pre`, `atom` and `std`.

  `mod`: recursive reference to the current module
  `pre`: parent module, including private members
  `atom`: top-level module and it's children's public memberss
  `std`: a standard library of generally useful Nix functions

  ## Future Work

  The Nix language itself could incorporate syntax like:

  ```
  {
    pub foo;
  }
  ```

  Here, `foo` could be implicitly defined in a similar, but more sophisticated way to Atom
  when not explicitly set.

  Further, Nix could introduce modules as top-level namespaces, with simplified syntax:

  ```
    foo = 1;
    pub bar = mod.foo;
  ```

  This would evaluate to `{ bar = 1; }` publicly and `{ foo, bar = 1; }` for child modules.

  These additions, combined with Atom's existing feature set, would:
  - Streamline development
  - Improve code clarity
  - Extend Nix's capabilities while preserving its core principles

  Atom, therefore, serves as a useable proof-of-concept for these ideas. Its ultimate goal is to
  inspire  improvements in the space that would eventually render Atom obsolete. By demonstrating
  these concepts, we aim to contribute to Nix's evolution and simplify complex operations for
  developers.

  Until such native functionality exists, Atom provides a glimpse of these
  possibilities within the current landscape.
*/
let
  l = builtins;
  src = import ./mod.nix;
in
{
  config,
  extern ? { },
  features ? [ ],
  # internal features of the composer function
  stdFeatures ? src.stdToml.features.default or [ ],
  coreFeatures ? src.coreToml.features.default,
  # enable testing code paths
  __internal__test ? false,
  __isStd__ ? false,
}:
dir':
let
  dir = src.prepDir dir';

  std = src.readStd {
    features = stdFeatures;
    inherit __internal__test;
  } ../std.toml;

  coreFeatures' = src.features.resolve src.coreToml.features coreFeatures;
  stdFeatures' = src.features.resolve src.stdToml.features stdFeatures;

  __atom = config // {
    features = config.features or { } // {
      resolved = {
        atom = features;
        core = coreFeatures';
        std = stdFeatures';
      };
    };
  };

  f =
    f: pre: dir:
    let
      contents = l.readDir dir;

      preOpt = {
        _if = pre != null;
        inherit pre;
      };

      scope =
        let
          scope' = with src; {
            inherit __atom;
            mod = self';
            builtins = errors.builtins;
            import = errors.import;
            scopedImport = errors.import;
            __fetchurl = errors.fetch;
            __currentSystem = errors.system;
            __currentTime = errors.time;
            __nixPath = errors.nixPath;
            __storePath = errors.storePath;
            __getEnv = errors.getEnv;
            __getFlake = errors.import;
          };

          scope'' = src.set.inject scope' [
            preOpt
            {
              _if = !__isStd__ && l.elem "std" coreFeatures';
              inherit std;
            }
            {
              _if = !__isStd__;
              atom = atom';
            }
            {
              _if = __isStd__;
              std = l.removeAttrs (extern // atom) [ "std" ];
            }
            {
              _if = __internal__test;
              # information about the internal module system itself
              # available to tests
              __internal = {
                # a copy of the global scope, for testing if values exist
                # for our internal testing functions
                scope = scope'';
                inherit src __isStd__ __internal__test;
              };
            }
          ];
        in
        scope'';

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = src.file.parse name;
        in
        if type == "directory" then
          { ${name} = f ((src.lowerKeys self) // src.set.when preOpt) path; }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          { ${file.name} = Import "${path}"; }
        else
          null # Ignore other file types
      ;

      self' = src.lowerKeys (l.removeAttrs self [ "mod" ] // { outPath = src.rmNixSrcs dir; });

      self =
        let
          mod = Import "${dir + "/mod.nix"}";
        in
        assert src.modIsValid mod dir;
        src.filterMap g contents // mod;

    in
    if src.hasMod contents then
      src.collectPublic self
    else
      # Base case: no module
      { };

  atom' = l.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf dir)
  ];

  atom =
    let
      fixed = src.fix f null dir;
    in
    src.set.inject fixed [
      (
        {
          _if = __isStd__;
        }
        // src.pureBuiltins
        // {
          path = fixed.path // {
            inherit (src.pureBuiltins) path;
          };
        }
      )
      {
        _if = __isStd__ && l.elem "lib" __atom.features.resolved.atom;
        inherit (extern) lib;
      }
      {
        _if = __isStd__ && __internal__test;
        __internal = {
          inherit __isStd__;
        };
      }
    ];
in
assert
  !__internal__test
  # older versions of Nix don't have the `warn` builtin
  || l.warn or l.trace ''
    in ${toString ./default.nix}:
    Internal testing functionality is enabled via the `__test` boolean.
    This should never be `true` except in internal test runs.
  '' true;
atom
