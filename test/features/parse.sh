#!/usr/bin/env bash

set -ex

f="$(nix eval -f parse.nix recursive-features.parsed)"
[[ "$f" == '[ "a" "b" "c" ]' ]]

f="$(nix eval -f parse.nix recursive-features-loop.parsed)"
[[ "$f" == '[ "a" "b" "c" ]' ]]
