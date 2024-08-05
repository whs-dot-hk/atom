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
}:
dir:
with src;
let
  std = composeStd ./std;

  __features' = src.features.parse toml.features __features;

  f =
    f: pre: dir':
    let
      # It is crucial that the directory is a path literal, not a string
      # since the implicit copy to the /nix/store, which provides isolation,
      # only happens for path literals.
      dir = strToPath dir';

      contents = l.readDir dir;

      preOpt = {
        _if = pre != null;
        inherit pre;
      };

      scope =
        let
          scope' = {
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
          };

          scope'' = injectOptionals scope' [
            preOpt
            {
              _if = l.elem "std" __features';
              std =
                std
                // cond {
                  _if = l.elem "pkg_lib" __features';
                  lib = import "${pins."nixpkgs.lib"}/lib";
                };
            }
          ];
        in
        scope''
        // {
          __internal = {
            features = __features';
            scope = scope'';
          };
        };

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = parse name;
        in
        if type == "directory" then
          { ${name} = f ((lowerKeys self) // cond preOpt) path; }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          { ${file.name} = Import "${path}"; }
        else
          null # Ignore other file types
      ;

      self' = lowerKeys (l.removeAttrs self [ "mod" ] // { outPath = rmNixSrcs dir; });

      self =
        let
          mod = Import "${dir + "/mod.nix"}";
        in
        assert modIsValid mod dir;
        filterMap g contents // mod;

    in
    if hasMod contents then
      collectPublic self
    else
      # Base case: no module
      { };

  atom' = l.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf dir)
  ];

  atom = fix f null dir;
in
atom
