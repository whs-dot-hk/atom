#!/usr/bin/env bash

set -ex

. ../common.sh

should_fail nix eval -f ./purity.nix builtins
should_fail nix eval -f ./purity.nix import
should_fail nix eval -f ./purity.nix scopedImport
should_fail nix eval -f ./purity.nix fetchurl
should_fail nix eval -f ./purity.nix currentTime
should_fail nix eval -f ./purity.nix currentSystem
should_fail nix eval -f ./purity.nix nixPath
should_fail nix eval -f ./purity.nix storePath
should_fail nix eval -f ./purity.nix getEnv
should_fail nix eval -f ./purity.nix getFlake
nix eval -f ./purity.nix std
