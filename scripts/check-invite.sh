#!/bin/sh
unset GREP_OPTIONS GREP_COLOR CDPATH ENV BASH_ENV
PATH=/usr/bin:/bin; export PATH
LC_ALL=C; export LC_ALL
set -eu
# Production ad9bcabc: operations.go:3914-3928; room_invites.go:122.
# Silent whole-argument checks; shell patterns operate on ASCII bytes.
fail() { printf '%s\n' 'Invalid room link; STOP.' >&2; exit 1; }
[ "$#" -eq 1 ] || fail
case "$1" in https://ouragentsync.com/join/*'#room='*) ;; *) fail ;; esac
rest=${1#https://ouragentsync.com/join/}
workspace=${rest%%#room=*}
fragment=${rest#*#room=}
case "$workspace" in ''|.|..|*[!A-Za-z0-9_.-]*) fail ;; esac
case "$fragment" in ''|*[!A-Za-z0-9_-]*) fail ;; esac
