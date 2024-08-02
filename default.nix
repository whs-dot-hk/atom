let
  fix = import ./std/fix.nix;
  filterMap = scopedImport { std = builtins; } ./std/set/filterMap.nix;
  parse = scopedImport { std = builtins; } ./std/file/parse.nix;
  compose = import ./.;
  cond = set: if set._if or true then set else { };

  filterMod = builtins.filterSource (
    path: type:
    let
      file = parse (baseNameOf path);
    in
    type == "regular" && file.ext or null != "nix"
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
  atom = fix (
    f: pre: dir:
    let
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
          _if = pre != { };
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
              self
              // cond {
                _if = pre != { };
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
      self
  ) { } dir;
in
atom
