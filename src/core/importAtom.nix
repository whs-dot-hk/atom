/**
  # `importAtom`

  > #### ⚠️ Warning ⚠️
  >
  > `importAtoms` current implementation should be reduced close to:
  > ```nix
  >   compose <| std.fromJSON
  > ```

  In other words, compose should receive a dynamically generated json from the CLI.

  If nix-lang gets some sort of native (and performant!) schema validation such as:
  [nixos/nix#5403](https://github.com/NixOS/nix/pull/5403) in the future, we can look at
  revalidating on the Nix side as an extra precaution, but initially, we just assume we have a
  valid input (and the CLI should type check on it's end)
*/
{
  __internal__test ? false,
}:
path':
let
  mod = import ./mod.nix;

  path = mod.prepDir path';

  file = builtins.readFile path;
  config = builtins.fromTOML file;
  atom = config.atom or { };
  id = builtins.seq version (atom.id or (mod.errors.missingAtom path' "id"));
  version = atom.version or (mod.errors.missingAtom path' "version");

  backend = config.backend or { };
  nix = backend.nix or { };
  defaultFetcher = nix.fetcher or "native"; # native doesn't exist yet

  src = builtins.seq id (
    let
      file = mod.parse (baseNameOf path);
      len = builtins.stringLength file.name;
    in
    builtins.substring 0 (len - 1) file.name
  );
  extern =
    let
      fetcherConfigs = config.fetcher or { };
    in
    mod.filterMap (
      k: v:
      let
        fetcher = v.fetcher or defaultFetcher;
        fetcherConfig = fetcherConfigs.${fetcher} or { };
        val = 
          if fetcher == "npins" then
            let
              npinsRoot = dirOf path + "/${fetcherConfig.root or "npins"}";
              pins = import npinsRoot;
              src = "${pins.${v.name or k}}/${v.subdir or ""}";
            in
            if v.import or false then
              if v.args or [ ] != [ ] then
                builtins.foldl' (
                  f: x:
                  let
                    intersect = x // (builtins.intersectAttrs x extern);
                  in
                  if builtins.isAttrs x then f intersect else f x
                ) (import src) v.args
              else
                import src
            else
              src
          else if fetcher == "local" then
            let
              localRoot = dirOf path + "/${fetcherConfig.root or ""}";
              localPath = mod.path.make localRoot (v.path or k);
            in
            mod.rmNixSrcs localPath
          # else if fetcher = "native", etc
          else
            null;
      in
      { "${k}" = val; }
    ) config.fetch or { };

  meta = atom.meta or { };

in
mod.compose {
  inherit
    extern
    __internal__test
    config
    src
    ;
  root = mod.prepDir (dirOf path);
  __isStd__ = meta.__is_std__ or false;
}
