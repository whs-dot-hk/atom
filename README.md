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

These features collectively provide a structured, introspectable, and efficient module system that enhances code organization and maintainability in Nix projects, while remaining otherwise unopinionated.

## A Module's Scope

### `mod`: Current Module

```nix
# string/mod.nix
{
  ToLower = mod.toLowerCase;
  Like = mod.like;
}

# string/toLowerCase.nix: mod.toLowerCase
str:
let
  head = std.substring 0 1 str;
  tail = std.substring 1 (-1) str;
in
"${mod.ToLower head}${tail}"
```

### `pre`: Parent Module Chain (Recursive)

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

## Eka's TOML Manifest (Unstable)

> #### ⚠️ The manifest's structure _will_ change as the project develops.
>
> The current in-repo manifest implementation is for demonstration purposes only.
> The canonical manifest validation layer exists in [`eka`](https://github.com/ekala-project/eka).

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

## Usage (Unstable)

> #### ⚠️ [Implementation detail](./src/atom/importAtom.nix)
>
> While it is conceptually useful to keep Atom minimal and in pure Nix, something like the code
> below should be implicit for user facing interfaces, e.g. [`eka`](https://github.com/ekala-project/eka).

```nix
let
  atom = builtins.fetchGit "https://github.com/ekala-project/atom";
  importAtom = import "${atom}/src/core/importAtom.nix";
in
importAtom {
  features = [
    # enabled flags
  ];
} ./src/dev.toml
```

## Future Directions: Ekala Platform

Atom lays the groundwork for the Ekala platform, which builds upon the innovative store-based build and distribution model introduced by Nix.

The Ekala project, through the `eka` CLI and its backend Eos API, aims to craft an open, unified platform that leverages the potential of this model to enhance software development, deployment, and system management at scale.

For details on `eka`, see the [eka README](https://github.com/ekala-project/eka/blob/master/README.md).

For ongoing discussions and updates, visit our [Issues](https://github.com/ekala-project/atom/issues) page.
