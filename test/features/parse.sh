#!/usr/bin/env bash

set -ex

f="$(nix eval -f parse.nix recursive-features.parsed)"
[[ "$f" == '[ "a" "b" "c" ]' ]]
