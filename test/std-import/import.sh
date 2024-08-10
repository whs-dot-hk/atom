#!/usr/bin/env bash

set -ex

# defaults
f="$(nix eval -f import.nix default.coreF)"
[[ "$f" == '[ "std" ]' ]]
f="$(nix eval -f import.nix default.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix default.lib)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix default.sanity)"
[[ "$f" == true ]]

# explicit
f="$(nix eval -f import.nix explicit.coreF)"
[[ "$f" == '[ "std" ]' ]]
f="$(nix eval -f import.nix explicit.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix explicit.lib)"
[[ "$f" == false ]]

# no std set
f="$(nix eval -f import.nix noStd.coreF)"
[[ "$f" == '[ ]' ]]
f="$(nix eval -f import.nix noStd.std)"
[[ "$f" == false ]]
f="$(nix eval -f import.nix noStd.lib)"
[[ "$f" == false ]]

# no std set
f="$(nix eval -f import.nix withLib.stdF)"
[[ "$f" == '[ "lib" ]' ]]
f="$(nix eval -f import.nix withLib.std)"
[[ "$f" == true ]]
f="$(nix eval -f import.nix withLib.lib)"
[[ "$f" == true ]]
