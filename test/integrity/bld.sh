#!/usr/bin/env bash
comp="$(nix eval -f ./bld.nix)"
res="$(nix eval -f ./bld.res.nix)"


if [[ "$comp" == "$res" ]]; then
   echo "success" && exit 0
fi
echo "failed" && exit 1
