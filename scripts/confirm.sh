#!/bin/sh
unset GREP_OPTIONS GREP_COLOR CDPATH ENV BASH_ENV
PATH=/usr/bin:/bin; export PATH
LC_ALL=C; export LC_ALL
set -eu
# Validate both values, then pass only the canonical CLI safety code.
fail() { printf 'STOP: %s\n' "$*" >&2; exit 1; }
[ "$#" -eq 2 ] || fail 'Expected host peer and relayed safety code.'
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
/bin/sh "$script_dir/check-value.sh" 'peer' "$1"
peer=$1
code=$2
case "${HOME:-}" in /*) ;; *) fail 'HOME must be absolute.' ;; esac
bridge_exe="$HOME/.local/bin/bridge"
[ ! -L "$bridge_exe" ] && [ -f "$bridge_exe" ] && [ -x "$bridge_exe" ] || fail 'Expected a regular executable at ~/.local/bin/bridge.'
[ -n "$(find "$bridge_exe" -prune -type f -user "$(id -u)" -print)" ] || fail 'The bridge executable must be owned by the current user.'
# Source the same silent validator so its normalized value is used directly.
set -- 'sas' "$code"
. "$script_dir/check-value.sh"
exec "$HOME/.local/bin/bridge" 'confirm-peer' '--peer' "$peer" '--sas' "$normalized_sas" '--via' 'phone' '--'
