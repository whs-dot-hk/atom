#!/usr/bin/env bash

set -ex

. ../common.sh

# defaults
nix eval -f import.nix default.std
should_fail nix eval -f import.nix default.lib

# no std set
should_fail nix eval -f import.nix noStd.std
should_fail nix eval -f import.nix noStd.lib

# no std set
nix eval -f import.nix withNixpkgsLib.std
nix eval -f import.nix withNixpkgsLib.lib

# no std set
should_fail nix eval -f import.nix noStdNixpkgs.std
should_fail nix eval -f import.nix noStdNixpkgs.lib
