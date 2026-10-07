#!/bin/sh
unset GREP_OPTIONS GREP_COLOR CDPATH ENV BASH_ENV
PATH=/usr/bin:/bin; export PATH
LC_ALL=C; export LC_ALL
set -eu
# Silent format checks. When sourced for sas, sets normalized_sas for confirm.sh.
fail() { printf '%s\n' 'Invalid join value; STOP.' >&2; exit 1; }
[ "$#" -eq 2 ] || fail
case "$1" in
    credential)
        case "$2" in abct_*) tail=${2#abct_} ;; *) fail ;; esac
        case "$tail" in ''|*[!A-Za-z0-9_-]*) fail ;; esac ;;
    peer)
        case "$2" in ''|human|[!A-Za-z0-9]*|*[!A-Za-z0-9_-]*) fail ;; esac
        [ "${#2}" -le 64 ] || fail ;;
    sas)
        case "$2" in ''|*[!A-Za-z0-9\ -]*) fail ;; esac
        # Strip ASCII spaces/dashes and uppercase, then restore CLI separators.
        # ad9bcabc pairing.go:380-386; local.go:1299-1309 (normalizer/word list).
        compact=$(printf '%s' "$2" | tr -d ' -' | tr 'a-z' 'A-Z')
        normalized_sas=
        for group in 1 2 3 4; do
            part=
            for digit in 1 2 3 4; do
                case "$compact" in [0-9A-F]*) ;; *) fail ;; esac
                rest=${compact#?}
                part=$part${compact%"$rest"}
                compact=$rest
            done
            normalized_sas=${normalized_sas:+$normalized_sas-}$part
        done
        for group in 1 2 3 4; do
            found=
            for word in ALPHA AMBER ARROW ATLAS BASIL BEACON BLUE BRAVE CABLE CEDAR CIVIC COAST DELTA DUSK ECHO EMBER FIELD FOCUS FORGE FROST GREEN HARBOR HAWK IVORY JASPER KEY LIME MAPLE NORTH ONYX ORBIT PEARL QUARTZ RIVER SAGE SLATE SOLAR STONE TIDE TIGER ULTRA VAULT VIOLET WEST WIND YELLOW ZENITH; do
                case "$compact" in "$word"*) found=$word; break ;; esac
            done
            [ -n "$found" ] || fail
            normalized_sas=$normalized_sas-$found
            compact=${compact#"$found"}
        done
        [ -z "$compact" ] || fail ;;
    *) fail ;;
esac
