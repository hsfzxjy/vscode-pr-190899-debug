__vsc_command_available() {
    builtin local trash
    trash=$(builtin command -v "$1" 2>&1)
    builtin return $?
}

__vsc_escape_value_fast1() {
    builtin local out
    # -An removes line number
    # -v do not use * to mark line suppression
    # -tx1 prints each byte as two-digit hex
    # tr -d '\n' concats all output lines
    out=$(od -An -vtx1 <<<"$1" | tr -d '\n')
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

content=$(for _ in $(seq 1 2100); do printf "\u$_"; done)

time __vsc_escape_value1 "${content}"
time __vsc_escape_value2 "${content}"