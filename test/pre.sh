set -ex

. ./common.sh

f="$(nix eval -f ./pre.nix sub.sub.out)"
[[ "$f" == true ]]

should_fail nix eval -f ./pre.nix sub.sub.fails
