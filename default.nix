let
  src = import ./src;
  l = builtins;
  pins = import ./npins;
in
{
  extern ? { },
  config ? builtins.fromTOML (builtins.readFile ./compose.toml),
}:
dir:
with src;
let
  std = composeStd ./std;

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
        injectOptionals
          {
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
          }
          [
            preOpt
            {
              _if = config.std.use or false;
              std =
                std
                // cond {
                  _if = config.std.nixpkgs_lib or false;
                  lib = import "${pins."nixpkgs.lib"}/lib";
                };
            }
          ];

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
