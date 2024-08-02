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
  pub ? { },
}:
dir:
let
  std = compose { } ./std // builtins;
  atom = fix (
    f: super: dir:
    let
      contents = builtins.readDir dir;

      hasMod = contents."mod.nix" or null == "regular";

      mod = if hasMod then scope "${dir + "/mod.nix"}" else { };

      scope = scopedImport (
        {
          inherit atom std;
          self = self // {
            outPath = filterMod dir;
          };
        }
        // cond {
          _if = super != { };
          inherit super;
        }
        // cond {
          _if = pub != { };
          inherit pub;
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
                _if = super != { };
                inherit super;
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
