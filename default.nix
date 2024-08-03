let
  fix = import ./std/fix.nix;
  filterMap = scopedImport { std = builtins; } ./std/set/filterMap.nix;
  parse = scopedImport { std = builtins; } ./std/file/parse.nix;
  strToPath = scopedImport { std = builtins; } ./std/path/strToPath.nix;
  cond = import ./std/set/cond.nix;
  compose = import ./.;

  filterMod = builtins.filterSource (
    path: type:
    let
      file = parse (baseNameOf path);
    in
    (type == "regular" && file.ext or null != "nix")
    || (type == "directory" && !builtins.pathExists "${path}/mod.nix")
  );

in
{
  extern ? { },
}:
dir:
let
  std = compose { } ./std // builtins;
  atom' = builtins.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf dir)
  ];
  stripPub =
    s:
    let
      s' = builtins.match "^pub_(.*)" s;
    in
    if s' == null then s else builtins.head s';

  rmPub = filterMap (k: v: { ${stripPub k} = v; });

  filterPub = filterMap (
    k: v:
    let
      s = stripPub k;
    in
    if s == k then null else { ${s} = v; }
  );

  atom = fix (
    f: pre: dir':
    let
      # It is crucial that the directory is a path literal, not a string
      # since the implicit copy to the /nix/store, which provides isolation,
      # only happens for path literals.
      dir = strToPath dir';

      contents = builtins.readDir dir;

      hasMod = contents."mod.nix" or null == "regular";

      mod = if hasMod then scope "${dir + "/mod.nix"}" else { };

      scope = scopedImport (
        {
          inherit std;
          atom = atom';
          mod = builtins.removeAttrs self [ "mod" ] // {
            outPath = filterMod dir;
          };
        }
        // cond {
          _if = pre != null;
          inherit pre;
        }
      );

      g =
        name: type:
        let
          path = dir + "/${name}";
          file = parse name;
        in
        if type == "directory" then
          {
            ${name} = f (
              (rmPub self)
              // cond {
                _if = pre != null;
                inherit pre;
              }
            ) path;
          }
        else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
          { ${file.name} = scope "${path}"; }
        else
          null # Ignore other file types
      ;

      self = filterMap g contents // mod;
    in
    if !hasMod then
      { } # Base case: no module
    else
      filterPub self
  ) null dir;
in
atom
