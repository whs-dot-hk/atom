#!/usr/bin/env bash

set -ex

f="$(nix eval -f resolve.nix recursive-features.resolved)"
[[ "$f" == '[ "a" "b" "c" ]' ]]

f="$(nix eval -f resolve.nix recursive-features-loop.resolved)"
[[ "$f" == '[ "a" "b" "c" ]' ]]
