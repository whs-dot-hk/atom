/**
  # `fromManifest`

  > Warning: This file is a temporary, hardcoded, solution to enable Atom's functionality.

  While Nix can parse JSON, generating this information outside of a Nix environment would be ideal.
  `fromManifest` is a demonstration feature, allowing users to experience Atom's capabilities now.

  Atom aims to be a valuable, unopinionated component for Nix developers, ensuring a bounded code
  collection phase. Its true entry point is the `compose` function, which is why it's maintained
  separately.

  We envision a language-agnostic space for expressing code typically found in IFD evaluations.
  This approach could eliminate the need for IFD by providing a uniform, versioned way to write
  logic that interfaces with a versioned API (`compose` inputs).

  The current proliferation of platform-specific derivations (e.g., `packages.(x86_|aarch)64-linux`)
  doesn't fully leverage Nix's purity. These should be generated inputs, validated against an API
  that rejects invalid entries early.

  This environment would address the drawbacks of current Nix IFD, offering a superior alternative
  to the status quo (2nix). It would avoid committing large portions of generated code or incurring
  the high cost of IFD evaluations. Instead, we could handle this part independently of Nix,
  creating a flat module space that allows for reasonable assumptions about our code.
*/
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
    mod.features.resolve featSet featIn;

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
    mod.features.resolve mod.atomToml.features feat;
  stdFeatures =
    let
      feat = composeFeatures.std or mod.stdToml.features.default;
    in
    mod.features.resolve mod.stdToml.features feat;

  __isStd__ = meta.__is_std__ or false;
} (dirOf path + "/${root}")
