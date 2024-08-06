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

  backend = config.backend or { };
  nix = backend.nix or { };
  lib = config.lib;
  compose = config.compose or { };

  root = lib.path;
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

  project = config.project or { };
  meta = project.meta or { };

in
(import ./compose.nix) {
  inherit extern __internal__test;
  features = features';
  composeFeatures =
    let
      features = compose.features or { };
    in
    src.features.parse src.composeToml.features features.atom;
  stdFeatures =
    let
      # std = features.std or { };
      std = features.std or src.stdToml.features.default;
    in
    src.features.parse src.stdToml.features std;

  __isStd__ = meta.__is_std__ or false;

} (dirOf path + "/${root}")
