> ⚠️ Warning: WIP Alpha ⚠️
>
> This is meant to deprecate current NixOS module mechanism as _legacy_ when it's ready, but we are not quite there yet.

# Nix Module System

A flexible and efficient module system for Nix, providing structured organization and composition of Nix code with strong isolation. By composing modules into discreet units referred to as "atoms" (akin to cargo crates, etc.), one can avoid the excessive cost of Nix boilerplate and focus on actual code, without sacrificing performance or flexibility.

Crucially, the system is designed to aid static analysis, so one can determine useful properties about your Nix
code without having to perform a full evaluation. This could be used, e.g. to ship off Nix files for evaluation on a more powerful remote machine, or for having a complete view of your code (including auto-complete) in your LSP.

## Key Features

- **Modular Structure**: Organize Nix code into directories, each defined by a `mod.nix` file.
- **Isolation**: Modules are imported into the Nix store, and manual imports are illegal, enforcing boundaries and preventing relative path access.
- **Introspection**: Unlike legacy modules, code is specified in its final form instead of as prototypes (functions), leading to much better and simpler introspective analysis.
- **Simplicity**: The system is kept purposefully simple and flexible in order to remain performant and useful.
- **Scoping**: Each module and member has access to `mod`, `pre`, `atom`, and `std`.
- **Standard Library**: Includes a standard library (`std`) augmented with `builtins`.

## How It Works

1. **Module Structure**:

   - `mod.nix`: Defines a module. Its presence is required for the directory to be treated as a module.
   - Other `.nix` files: Automatically imported as module members.
   - Subdirectories with `mod.nix`: Treated as nested modules.
   - Capitalized outputs are public (everything else is private by default)
   - `mod.outPath` refers to the current module's directory filtered of any nix files or modules, for accessing static files privately

2. **Scoping**:

   - `mod`: Current module, includes `outPath` for accessing non-Nix files.
   - `pre`: Parent module (if applicable) with private members; recursive back to the root.
   - `atom`: Top-level module and external dependencies with only public members.
   - `std`: Standard library and `builtins`.

3. **Composition**: Modules are composed recursively, with `mod.nix` contents taking precedence.

4. **Isolation**: Modules are imported into the Nix store as plan files, enforcing boundaries as they cannot access their relative paths directly.

5. **Encapsulation**: implementation details can be cleanly hidden with private module members by default. See: [#5](https://github.com/ekala-project/modules/pull/5) [#6](https://github.com/ekala-project/modules/pull/6)

## Usage

```nix
let
  compose = import ./path/to/this/module/system;
  myModule = compose ./path/to/my/atom/root;
in
  myModule
```

## Best Practices

- Always use "mod.nix" to define a module in a directory, and prefer it to specify the modules public interface.
- Break out large functions or code blocks into their own files
- Organize related functionality into subdirectories with their own "mod.nix" files.
- Leverage provided scopes for clean, modular and self-contained code.
- Use `"${mod}/foo.nix"` when needing to access non-Nix files within a module.

## Future Work

- Extensible CLI with static analysis powers, and more (eka)
- Static manifest format (we now have a draft)
- tooling integration (LSP, etc)
- demonstrating the efficient output spec envisioned for efficient evaluation & builds
- unit testing modules
- how to and extensive docs of core features
