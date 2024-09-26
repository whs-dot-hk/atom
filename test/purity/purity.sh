#!/usr/bin/env bash

set -ex

. ../common.sh

nix eval -f ./purity.nix builtins
nix eval -f ./purity.nix currentTime
nix eval -f ./purity.nix nixPath
nix eval -f ./purity.nix getEnv
should_fail nix eval -f ./purity.nix import
should_fail nix eval -f ./purity.nix scopedImport
should_fail nix eval -f ./purity.nix fetchurl
should_fail nix eval -f ./purity.nix currentSystem
should_fail nix eval -f ./purity.nix storePath
should_fail nix eval -f ./purity.nix getFlake
nix eval -f ./purity.nix std
