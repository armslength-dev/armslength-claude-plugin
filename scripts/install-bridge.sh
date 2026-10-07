#!/bin/sh
unset GREP_OPTIONS GREP_COLOR CDPATH ENV BASH_ENV
PATH=/usr/bin:/bin; export PATH
LC_ALL=C; export LC_ALL
set -eu
# ONE Bash call. Target: production install.sh.tmpl:64-65,141 (ad9bcabc).
fail() { printf 'STOP: %s\n' "$*" >&2; exit 1; }
case "$(uname -s)" in Darwin|Linux) ;; *) fail 'Native Windows is unsupported; use macOS or the browser join.' ;; esac
case "${HOME:-}" in /*) ;; *) fail 'HOME must be absolute.' ;; esac
bridge_exe="$HOME/.local/bin/bridge"
check_binary() {
    [ ! -L "$bridge_exe" ] && [ -f "$bridge_exe" ] && [ -x "$bridge_exe" ] || fail 'Expected a regular executable at ~/.local/bin/bridge.'
    [ -n "$(find "$bridge_exe" -prune -type f -user "$(id -u)" -print)" ] || fail 'The bridge executable must be owned by the current user.'
    bridge_version=$("$bridge_exe" version 2>/dev/null) || fail 'Installed bridge version failed; keep it and ask the person.'
    first_line=$(printf '%s\n' "$bridge_version" | sed -n '1p')
    printf '%s\n' "$first_line" | grep -Eqx 'bridge v[0-9]+\.[0-9]+\.[0-9]+' || fail 'Unrecognized installed version; keep it and ask the person.'
    printf '%.80s\n' "$first_line"
}
if [ -e "$bridge_exe" ] || [ -L "$bridge_exe" ]; then
    check_binary
    exit 0
fi
install_tmp=$(mktemp -d) || fail 'Cannot create installer directory.'
cleanup() {
    # Only these two files in the private directory; never recursive removal.
    rm -- "$install_tmp/install.sh" "$install_tmp/install.log" 2>/dev/null || :
    rmdir -- "$install_tmp" 2>/dev/null || :
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
curl --proto '=https' --tlsv1.2 -fsSL --proto-redir '=https' -o "$install_tmp/install.sh" 'https://ouragentsync.com/install.sh' 2>/dev/null || fail 'Installer download failed.'
if /bin/sh "$install_tmp/install.sh" > "$install_tmp/install.log" 2>&1; then
    :
else
    if grep -Eq 'predates signed releases.*remove /(usr/)?s?bin/bridge' "$install_tmp/install.log"; then
        printf '%s\n' "Your system has an unrelated networking tool also called bridge; the armslength installer can't proceed on this machine yet. Please use macOS or the browser join." >&2
        exit 1
    fi
    fail 'Installer refused or exited non-zero; do not retry around the refusal. Ask armslength support.'
fi
grep -qx 'release verified' "$install_tmp/install.log" || fail 'Installer did not print release verified.'
check_binary
printf '%s\n' 'release verified' 'First-install trust: the downloaded binary verified itself.'
