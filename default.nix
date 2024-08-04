let
  fix = import ./std/fix.nix;
  filterMap = scopedImport { std = builtins; } ./std/set/filterMap.nix;
  parse = scopedImport { std = builtins; } ./std/file/parse.nix;
  strToPath = scopedImport { std = builtins; } ./std/path/strToPath.nix;
  toLowerCase = scopedImport rec {
    std = builtins;
    mod = scopedImport { inherit std mod; } ./std/string/mod.nix;
  } ./std/string/toLowerCase.nix;
  cond = import ./std/set/cond.nix;
  compose = import ./.;

  lowerKeys = filterMap (k: v: { ${toLowerCase k} = v; });
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
  std =
    compose { } ./std
    // filterMap (
      k: v:
      if
        builtins.match "^import|^scopedImport|^builtins|^fetch.*|^current.*|^nixPath|^storePath" k != null
      then
        null
      else
        { ${k} = v; }
    ) builtins;
  atom' = builtins.removeAttrs (extern // atom // { inherit extern; }) [
    "atom"
    (baseNameOf dir)
  ];

  filterPub = filterMap (
    k: v:
    let
      s = toLowerCase k;
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

      scope =
        let
          importErr = "Importing arbitrary Nix files is forbidden. Declare your dependencies via the module system instead.";
        in
        scopedImport (
          {
            inherit std;
            atom = atom';
            mod = lowerKeys (builtins.removeAttrs self [ "mod" ] // { outPath = filterMod dir; });
            # override builtins, so they can only be accessed via `std`
            builtins = abort "Please access builtins uniformly via the `std` scope.";
            import = abort importErr;
            scopedImport = abort importErr;
            __fetchurl = abort "Ad hoc fetching is illegal. Declare dependencies statically in the manifest instead.";
            __currentSystem = abort "Accessing the current system is impure. Declare supported systems in the manifest.";
            __currentTime = abort "Accessing the current time is impure & illegal.";
            __nixPath = abort "The NIX_PATH is an impure feature, and therefore illegal.";
            __storePath = abort "Making explicit dependencies on store paths is illegal.";

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
              (lowerKeys self)
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
