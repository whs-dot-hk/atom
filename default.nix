{
  features ? null,
  __internal__test ? false,
}:
path':
let
  src = import ./src;
  path = src.prepDir path';
  config = builtins.fromTOML (builtins.readFile path);
  features' =
    let
      featSet = config.features or { };
      featIn = if features == null then featSet.default or [ ] else features;
    in
    src.features.parse featSet featIn;

  backends = config.backends or { };
  nix = backends.nix or { };
  composer = config.composer or { };

  root = nix.root or "nix";
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
      src.filterMap (
        k: v:
        let
          src = "${pins.${v.name or k}}/${v.sub or ""}";
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

  project = config.project or { };
  meta = project.meta or { };

in
(import ./compose.nix) {
  inherit extern __internal__test;
  features = features';
  composeFeatures =
    let
      features = composer.features or src.composeToml.features.default;
    in
    src.features.parse src.composeToml.features features;
  stdFeatures =
    let
      std = composer.std or { };
      features = std.features or src.stdToml.features.default;
    in
    src.features.parse src.stdToml.features features;

  __isStd__ = meta.__is_std__ or false;

} (dirOf path + "/${root}")
