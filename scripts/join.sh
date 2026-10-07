#!/bin/sh
unset GREP_OPTIONS GREP_COLOR CDPATH ENV BASH_ENV
PATH=/usr/bin:/bin; export PATH
LC_ALL=C; export LC_ALL
set -eu
# Validate and execute the same argv. Never resolve bridge through PATH.
fail() { printf 'STOP: %s\n' "$*" >&2; exit 1; }
[ "$#" -eq 2 ] || fail 'Expected room link and credential.'
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
/bin/sh "$script_dir/check-invite.sh" "$1"
/bin/sh "$script_dir/check-value.sh" 'credential' "$2"
case "${HOME:-}" in /*) ;; *) fail 'HOME must be absolute.' ;; esac
bridge_exe="$HOME/.local/bin/bridge"
[ ! -L "$bridge_exe" ] && [ -f "$bridge_exe" ] && [ -x "$bridge_exe" ] || fail 'Expected a regular executable at ~/.local/bin/bridge.'
[ -n "$(find "$bridge_exe" -prune -type f -user "$(id -u)" -print)" ] || fail 'The bridge executable must be owned by the current user.'
# Cobra room_cmd.go:52-55: flags precede --; exactly one positional link.
exec "$HOME/.local/bin/bridge" 'room' 'join' '--credential' "$2" '--' "$1"
