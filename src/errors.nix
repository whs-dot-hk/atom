{
  import = abort "Importing arbitrary Nix files is forbidden. Declare your dependencies via the module system instead.";
  builtins = abort "Please access builtins uniformly via the `std` scope.";
  fetch = abort "Ad hoc fetching is illegal. Declare dependencies statically in the manifest instead.";
  system = abort "Accessing the current system is impure. Declare supported systems in the manifest.";
  time = abort "Accessing the current time is impure & illegal.";
  nixPath = abort "The NIX_PATH is an impure feature, and therefore illegal.";
  storePath = abort "Making explicit dependencies on store paths is illegal.";
}
