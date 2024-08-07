{
  features ? null,
  __internal__test ? false,
}:
path':
let
  mod = import ./mod.nix;

  path = mod.prepDir path';

  file = builtins.readFile path;
  config = builtins.fromTOML file;
  atom = config.atom or { };
  name = atom.name or (mod.errors.missingName path);

  features' =
    let
      featSet = config.features or { };
      featIn = if features == null then featSet.default or [ ] else features;
    in
    mod.features.parse featSet featIn;

  backend = config.backend or { };
  nix = backend.nix or { };
  compose = config.compose or { };

  root = atom.path or name;
  extern =
    let
      fetcher = nix.fetcher or "native"; # native doesn't exist yet
      conf = config.fetcher or { };
      f = conf.${fetcher} or { };
      root = f.root or "npins";
    in
    if fetcher == "npins" then
      let
        pins = import (dirOf path + "/${root}");
      in
      mod.filterMap (
        k: v:
        let
          src = "${pins.${v.name or k}}/${v.subdir or ""}";
          val =
            if v.import or false then
              if v.args or [ ] != [ ] then builtins.foldl' (f: x: f x) (import src) v.args else import src
            else
              src;
        in
        if (v.optional or false && builtins.elem k features') || (!v.optional or false) then
          { "${k}" = val; }
        else
          null
      ) config.fetch or { }
    # else if fetcher = "native", etc
    else
      { };

  meta = atom.meta or { };

  composeFeatures = compose.features or { };
in
(mod.compose) {
  inherit extern __internal__test config;
  features = features';
  composeFeatures =
    let
      feat = composeFeatures.atom or mod.atomToml.features.default;
    in
    mod.features.parse mod.atomToml.features feat;
  stdFeatures =
    let
      feat = composeFeatures.std or mod.stdToml.features.default;
    in
    mod.features.parse mod.stdToml.features feat;

  __isStd__ = meta.__is_std__ or false;
} (dirOf path + "/${root}")
