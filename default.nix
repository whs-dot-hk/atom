path':
let
  src = import ./src;
  path = src.prepDir path';
  config = builtins.fromTOML (builtins.readFile path);
  features =
    let
      f = config.features or { };
    in
    src.features.parse f f.default or [ ];

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
      builtins.mapAttrs (
        k: v:
        let
          src = pins.${v.name or k};
        in
        if v.import or false then
          if v.args or [ ] != [ ] then builtins.foldl' (f: x: f x) (import src) v.args else import src
        else
          src
      ) config.fetch or { }
    # else if fetcher = "native", etc
    else
      { };

in
(import ./compose.nix) {
  inherit features extern;
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
    src.features.parse src.composeToml.features features;

} (dirOf path + "/${root}")
