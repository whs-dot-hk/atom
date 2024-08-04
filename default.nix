let
  src = import ./src;
  l = builtins;
in
{
  extern ? { },
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

      scope = injectPrevious pre {
        inherit std;
        atom = atom';
        mod = lowerKeys (l.removeAttrs self [ "mod" ] // { outPath = filterMod dir; });
        builtins = errors.builtins;
        import = errors.import;
        scopedImport = errors.import;
        __fetchurl = errors.fetch;
        __currentSystem = errors.system;
        __currentTime = errors.time;
        __nixPath = errors.nixPath;
        __storePath = errors.storePath;
      };

      Import = scopedImport scope;

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = parse name;
        in
        if type == "directory" then
          { ${name} = f (injectPrevious pre (lowerKeys self)) path; }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          { ${file.name} = Import "${path}"; }
        else
          null # Ignore other file types
      ;

      self =
        let
          mod = Import "${dir + "/mod.nix"}";
        in
        assert modIsValid mod dir;
        filterMap g contents // mod;

    in
    if hasMod contents then
      filterPub self
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
