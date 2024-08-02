> ⚠️ Warning: WIP Alpha ⚠️
>
> This is meant to deprecate current NixOS module mechanism as *legacy* when it's ready, but we are not quite there yet.

# Nix Module System

A flexible and efficient module system for Nix, providing structured organization and composition of Nix code with strong isolation. By composing modules into discreet units referred to as "atoms" (akin to cargo crates, etc.), one can avoid the excessive cost of Nix boilerplate and focus on actual code, without sacrificing performance or flexibility.

Crucially, the system is designed to aid static analysis, so one can determine useful properties about your Nix
code without having to perform a full evaluation. This could be used, e.g. to ship off Nix files for evaluation on a more powerful remote machine, or for having a complete view of your code (including auto-complete) in your LSP.

## Key Features

- **Modular Structure**: Organize Nix code into directories, each defined by a `mod.nix` file.
- **Automatic Importing**: Nix files in a module directory are automatically imported.
- **Isolation**: Modules are imported into the Nix store, enforcing boundaries and preventing relative path access.
- **Introspection**: Unlike legacy modules, code is specified in its final form instead of as prototypes (functions), leading to much better and simpler introspective analysis.
- **Simplicity**: The system is kept purposefully simple and flexible in order to remain performant and flexible.
- **Scoping**: Each module and member has access to `mod`, `pre`, `atom`, and `std`.
- **Standard Library**: Includes a standard library (`std`) augmented with `builtins`.

## How It Works

1. **Module Structure**:
   - `mod.nix`: Defines a module. Its presence is required for the directory to be treated as a module.
   - Other `.nix` files: Automatically imported as module members.
   - Subdirectories with `mod.nix`: Treated as nested modules.

2. **Scoping**:
   - `mod`: Current module, includes `outPath` for accessing non-Nix files.
   - `pre`: Parent module (if applicable).
   - `atom`: Top-level module and external dependencies.
   - `std`: Standard library and `builtins`.

3. **Composition**: Modules are composed recursively, with `mod.nix` contents taking precedence.

4. **Isolation**: Modules are imported into the Nix store, enforcing boundaries.

## Usage

```nix
let
  compose = import ./path/to/this/module/system;
  myModule = compose ./path/to/my/atom/root;
in
  myModule
```

## Best Practices

* Always use "mod.nix" to define a module in a directory.
* Break out large functions or code blocks into their own files
* Organize related functionality into subdirectories with their own "mod.nix" files.
* Leverage provided scopes for clean, modular code.
* Use `"${mod}/foo.nix"` when needing to access non-Nix files within a module.

## Future Work

* private members
* CLI with static analysis powers (eka)
* Static manifest format
* tooling integration (LSP, etc)
* atom composition (remote atoms, mono-repos, flake and legacy expression integration, etc)
