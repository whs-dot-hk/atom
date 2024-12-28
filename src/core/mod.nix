# to avoid excessive recursion that can lead to inefficiency or errors
# we cannot compose the individual pieces of the module composer as a regular module
# so instead we abstract them out here, into a manually specified "psuedo-module"
# to keep the core impelementation clean
let
  importAtom = import ./importAtom.nix;
  fix = import ../std/fix.nix;
  when = scopedImport { } ../std/set/when.nix;
  inject = scopedImport {
    mod = {
      inherit when;
    };
  } ../std/set/inject.nix;
  filterMap = scopedImport { } ../std/set/filterMap.nix;
  make = scopedImport { } ../std/path/make.nix;
  parse = scopedImport { } ../std/file/parse.nix;
  toLowerCase = scopedImport rec {
    mod = scopedImport { inherit mod; } ../std/string/mod.nix;
  } ../std/string/toLowerCase.nix;
in
rec {
  inherit
    fix
    parse
    filterMap
    ;

  path = {
    inherit make;
  };

  file = {
    inherit parse;
  };
  set = {
    inherit inject when;
  };

  compose = import ./compose.nix;

  errors = import ./errors.nix;

  lowerKeys = filterMap (k: v: { ${toLowerCase k} = v; });

  collectPublic = filterMap (
    k: v:
    let
      s = toLowerCase k;
    in
    if s == k then null else { ${s} = v; }
  );

  rmNixSrcs =
    path:
    let
      name = baseNameOf path;
    in
    builtins.path {
      inherit name path;
      filter = (
        path: type:
        let
          file = parse path;
        in
        (type == "regular" && file.ext or null != "nix")
        || (type == "directory" && !builtins.pathExists "${path}/mod.nix")
      );
    };

  importStd = opts: importAtom { inherit (opts) __internal__test; };

  modIsValid =
    mod: dir:
    builtins.isAttrs mod
    || throw ''
      The following module does not evaluate to a valid attribute set:
             ${toString dir}/mod.nix
    '';

  hasMod = contents: contents."mod.nix" or null == "regular";

  # It is crucial that the directory is a path literal, not a string
  # since the implicit copy to the /nix/store, which provides isolation,
  # only happens for path literals.
  prepDir =
    dir:
    let
      dir' =
        if builtins.match "^${builtins.storeDir}/.+" dir != null then
          # this is safe because we will never reimport the full path back to the store
          # only specific files within it, which will have their own context when converted
          # back to a string.
          builtins.unsafeDiscardStringContext dir
        else
          dir;
    in
    if builtins.isPath dir then dir else make /. dir';
}
