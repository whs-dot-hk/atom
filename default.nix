let
  fix = import ./std/fix.nix;
  filterMap = scopedImport { std = builtins; } ./std/set/filterMap.nix;
  parse = scopedImport { std = builtins; } ./std/file/parse.nix;
  compose = import ./.;

  filterMod = builtins.filterSource (
    path: type:
    let
      file = parse (baseNameOf path);
    in
    type == "regular" && file.ext or null != "nix"
  );

in
dir:
let
  atom = fix (
    f: super: dir:
    let
      contents = builtins.readDir dir;
      self =
        let
          import' = scopedImport (
            {
              inherit atom;
              std = compose ./std // builtins;
              self = self // {
                outPath = filterMod dir;
              };
            }
            // (if super != { } then { inherit super; } else { })
          );
          mod =
            if contents ? "mod.nix" && contents."mod.nix" == "regular" then
              import' "${dir + "/mod.nix"}"
            else
              { };
        in
        filterMap (
          name: type:
          let
            path = dir + "/${name}";
            file = parse name;
          in
          if type == "directory" then
            { ${name} = f self path; }
          else if type == "regular" && file.ext or null == "nix" && name != "mod.nix" then
            { ${file.name} = import' "${path}"; }
          else
            null # Ignore other file types
        ) contents
        // mod;
    in
    if !(contents."mod.nix" or null == "regular") then
      { } # Base case: no module
    else
      self
  ) { } dir;
in
atom
