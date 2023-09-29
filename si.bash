__vsc_command_available() {
    builtin local trash
    trash=$(builtin command -v "$1" 2>&1)
    builtin return $?
}

__vsc_escape_value_fast1() {
    builtin local out LC_ALL=C length
    # -An removes line number
    # -v do not use * to mark line suppression
    # -tx1 prints each byte as two-digit hex
    # tr -d '\n' concats all output lines
    out=$(od -An -vtx1 <<<"$1" | tr -s '[:space:]' ' ')
    # strip the last newline
    length=${#out}
    out=${out:0:length-1}

    out=${out// /\\x}
    # <<<"$1" prepends a trailing newline already, so we don't need to printf '%s\n'
    builtin printf '%s' "${out}"
}

__vsc_escape_value_fast2() {
    builtin local LC_ALL=C out
    out=${1//\\/\\\\}
    out=${out//;/\\x3b}
    builtin printf '%s\n' "${out}"
}

# The property (P) and command (E) codes embed values which require escaping.
# Backslashes are doubled. Non-alphanumeric characters are converted to escaped hex.
__vsc_escape_value1() {
    # If the input being too large, switch to the faster function
    if [ "${#1}" -ge 2000 ]; then
        __vsc_escape_value_fast1 "$1"
        builtin return
    fi
}

__vsc_escape_value2() {
    # If the input being too large, switch to the faster function
    if [ "${#1}" -ge 2000 ]; then
        __vsc_escape_value_fast2 "$1"
        builtin return
    fi
}

make_sample() {
    builtin local i j
    for i in $(seq 1 $1); do
        j=$(printf "%x" $(($i % 254 + 1)))
        printf "\x${j}"
    done
}



content=$(make_sample 2010)
time __vsc_escape_value1 "${content}"
time __vsc_escape_value2 "${content}"

content=$(make_sample 6000)
time __vsc_escape_value1 "${content}"
time __vsc_escape_value2 "${content}"
