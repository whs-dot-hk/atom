#!/usr/bin/env bash

set -ex

# defaults
f="$(nix eval -f import.nix default.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix default.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix default.compose)"
[[ "$f" == '[ "std" ]' ]]

# explicit
f="$(nix eval -f import.nix explicit.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix explicit.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix explicit.compose)"
[[ "$f" == '[ "std" ]' ]]

# no std set
f="$(nix eval -f import.nix noStd.std)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.compose)"
[[ "$f" == '[ ]' ]]

# no std set
f="$(nix eval -f import.nix withNixpkgsLib.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withNixpkgsLib.lib)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withNixpkgsLib.stdF)"
[[ "$f" == '[ "pkg_lib" "lib" ]' ]]
