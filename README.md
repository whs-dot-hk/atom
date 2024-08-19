# Atom: Next-Gen Nix Module System

> ⚠️ Warning: WIP Alpha ⚠️

Atom is a lean, efficient module system for Nix, designed to be independently useful. As a standalone tool, it offers powerful modular capabilities for Nix users today. Simultaneously, it acts as the inaugural component of the Ekala project, laying the groundwork for future ecosystem development.

Atom's design facilitates a novel capability in the Nix ecosystem: the potential for efficient operations without full Nix expression evaluation. This feature, not currently available in standard Nix tooling, is specifically crafted to be leveraged by higher-level tooling in the forthcoming Ekala ecosystem.

## Module Structure

Modules in Atom are directories with a `mod.nix` file containing an attribute set, with subdirectories of the same structure forming submodules. Features include:

- **Explicit Scope**: All other `.nix` files in the module directory are implicitly imported as module members with their associated scope. Manual `import` is prohibited, ensuring a consistent global namespace.
- **Predictable Composition**: _O(n)_ for shallow, _O(n \* log(m))_ for deep nesting.
- **Direct Type Declaration**: Enables declaring code as its intended type without function wrappers. Enhances Nix's introspection capabilities, allowing complete Atom exploration in REPLs, while laying groundwork for future static analysis tooling.
- **Public/Private Distinction**: Capitalized members denote public exports; all others are private by default.
- **Static File Access**: `mod.outPath` provides access to non-Nix files, excluding submodules, offering an efficient file system API with a well-defined scope.

These features collectively provide a structured, introspectable, and efficient module system that enhances code organization and maintainability in Nix projects.

## Scoping Examples

### `mod`: Current Module

```nix
# string/mod.nix
{
  ToLower = mod.toLowerCase;
  Like = mod.like;
}

# string/toLowerCase.nix
str:
let
  head = std.substring 0 1 str;
  tail = std.substring 1 (-1) str;
in
"${mod.ToLower head}${tail}"
```

### `pre`: Parent Module Chain

```nix
# parent/mod.nix
{
  privateHelper = x: x * 2;
  PublicFunc = x: x + 1;
}

# parent/child/mod.nix
{
  UseParentPrivate = x: pre.privateHelper x;
  UseParentPublic = x: pre.PublicFunc x;
}
```

### `atom`: Top-level and Dependencies

```nix
# root/mod.nix
{
  RootFunc = x: x * 3;
}

# nested/deep/mod.nix
{
  UseRoot = x: atom.RootFunc x;
}
```

### `std`: Standard Library

```nix
# utils/mod.nix
{
  Double = x: std.mul 2 x;
  IsEven = x: std.mod x 2 == 0;
}
```

## Ekala TOML Manifest (Unstable)

> ⚠️ The manifest's structure _will_ change as the project develops.

Each atom is defined by a TOML manifest file, enhancing dependency tracking and separation of concerns:

```toml
[atom]
name = "dev"
version = "0.1.0"
description = "Development environment"

[features]
default = []

[fetch.pkgs]
name = "nixpkgs"
import = true
args = [{}]
```

### Demonstrated Components:

- Atom metadata
- Feature flags
- Legacy Nix expression fetching (e.g., nixpkgs)

Atoms are designed to accommodate a future plugin-based schema extension system, envisioned for the theoretical CLI: [`eka`](#future-cli-eka). In this proposed framework, `[atom]` and `[features]` would serve as foundational elements, while `[fetch]` illustrates a potential Nix-specific plugin feature.

Exact dependency and composition semantics are still evolving. For updates relating to the high-level format, see:

- [Compositional Semantics #19](https://github.com/ekala-project/atom/issues/19)
- [Manifest Stabilization #31](https://github.com/ekala-project/atom/issues/31)

## Usage

> ⚠️ [Implementation detail](./src/atom/fromManifest.nix): The TOML Manifest is the true entrypoint. Future CLI will respect this.

```nix
let
  atom = builtins.fetchGit "https://github.com/ekala-project/atom";
  fromManifest = import "${atom}/src/core/fromManifest.nix";
in
fromManifest {
  features = [
    # optional feature flags
  ];
} ./src/dev.toml # or specific manifest file
```

## Future Directions: Ekala CLI (`eka`)

Atom lays the groundwork for `eka`, a key component of the Ekala project. Ekala aims to create a unified platform leveraging store-based build systems.

The Ekala project, through `eka` and its backend Eos API, targets improvements in software development, deployment, and system management at scale.

For details on `eka`, see the [eka README](https://github.com/ekala-project/eka/blob/master/README.md).

For ongoing discussions and updates, visit our [Issues](https://github.com/ekala-project/atom/issues) page.
