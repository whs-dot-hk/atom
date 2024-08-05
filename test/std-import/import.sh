#!/usr/bin/env bash

set -ex

# defaults
f="$(nix eval -f import.nix default.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix default.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix default.core)"
[[ "$f" == '[ "std" ]' ]]

# explicit
f="$(nix eval -f import.nix explicit.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix explicit.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix explicit.core)"
[[ "$f" == '[ "std" ]' ]]

# no std set
f="$(nix eval -f import.nix noStd.std)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.core)"
[[ "$f" == '[ ]' ]]

# no std set
f="$(nix eval -f import.nix withNixpkgsLib.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withNixpkgsLib.lib)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withNixpkgsLib.core)"
[[ "$f" == '[ "pkg_lib" "std" ]' ]]
