#!/usr/bin/env bash
set -euo pipefail


grab_subs() {
    ffmpeg -y -i "$1" -map 0:s:0 -f srt /dev/stdout 2>/dev/null
}


gif() {
    ffmpeg \
        -y -i "$1" -r 15 \
        -vf "subtitles=$1, scale=512:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
        -ss "$2" -to "$3" \
        "${4}.gif"
}


search_subs() {
    function preview() {
        line=$(awk '{print $1}' <<< "$1")
        if [[ $line -lt 6 ]]; then line=6; fi
        sed -n "$((line - 5)),$((line + 5))p" "$2"
    }
    exec 8<<< "$1"
    exec 9<<< "$(declare -f preview); preview \"\$@\""
    match=$(
        nl -b a -p -n ln /dev/fd/8 \
        | grep -v -- '-->' \
        | grep -Pv '^[0-9]+\s+[0-9]*$' \
        | fzf +m --with-nth 2.. --preview 'bash /dev/fd/9 {} /dev/fd/8'
    )
    if [[ $? -ne 0 ]]; then exit 1; fi
    line=$(awk '{print $1}' <<< "$match")
    head -n "$line" /dev/fd/8 | grep -- '-->' | tr ',' '.' | tail -1
}


cleanup() {
    if [[ -f "${SHORTFILE:-}" ]]; then
        rm -f "$SHORTFILE"
    fi
}


main() {
    INPUT="$1"
    OUTPUT="$2"

    if [[ -d "$INPUT" ]]; then
        INPUT=$(find "$INPUT" -type f | fzf +m)
    fi

    FILENAME=$(basename -- "$INPUT")
    EXTENSION="${FILENAME##*.}"
    SHORTFILE="$(mktemp -u XXXXXX."${EXTENSION}")"

    ln -sf "$INPUT" "$SHORTFILE"
    INPUT="$SHORTFILE"

    SUBS=$(grab_subs "$INPUT")

    START=$(search_subs "$SUBS" | awk '{ print $1 }')

    END=$(search_subs "$SUBS" | awk '{ print $3 }')

    set -x
    gif "$INPUT" "$START" "$END" "$OUTPUT"
}


trap cleanup INT TERM EXIT

main "$@"
