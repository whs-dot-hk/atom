let
  l = builtins;
  src = import ./src;
  pins = import ./npins;
  toml = l.fromTOML (l.readFile ./compose.toml);
in
{
  extern ? { },
  # internal features of the composer function
  __features ? toml.features.default or [ ],
  # enable testing code paths
  __internal__test ? false,
}:
dir':
let
  dir = src.prepDir dir';

  std = src.composeStd ./std;

  __features' = src.features.parse toml.features __features;

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
            atom = atom';
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
            __getFlake = error.import;
          };

          scope'' = src.injectOptionals scope' [
            preOpt
            {
              _if = l.elem "std" __features';
              std =
                std
                // src.set.cond {
                  _if = l.elem "pkg_lib" __features';
                  lib = import "${pins."nixpkgs.lib"}/lib";
                };
            }
          ];
        in
        scope''
        // src.set.cond {
          _if = __internal__test;
          # information about the internal module system itself
          __internal = {
            features = __features';
            # a copy of the global scope, for testing if values exist
            # mostly for our internal testing functions
            scope = scope'';
          };
        };

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = src.file.parse name;
        in
        if type == "directory" then
          { ${name} = f ((src.lowerKeys self) // src.set.cond preOpt) path; }
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

  atom = src.fix f null dir;
in
assert
  !__internal__test
  || l.warn ''
    in ${toString ./default.nix}:
    Internal testing functionality is enabled via the `__test` boolean.
    This should never be `true` except in internal test runs.
  '' true;
atom
