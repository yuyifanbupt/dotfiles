#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [message] [title]\n' "${0##*/}" >&2
  printf '       command | %s [--] [title]\n' "${0##*/}" >&2
}

if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$#" -gt 2 ]; then
  usage
  exit 2
fi

if [ "$#" -gt 0 ] && [ "${1-}" != "--" ]; then
  message=$1
  title=${2:-Terminal}
else
  message=$(cat)
  if [ "${1-}" = "--" ]; then
    title=${2:-Terminal}
  else
    title=Terminal
  fi
fi

if [ "$(uname -s)" = "Darwin" ]; then
  osascript - "$title" "$message" <<'APPLESCRIPT'
on run argv
  display notification (item 2 of argv) with title (item 1 of argv)
end run
APPLESCRIPT
  exit 0
fi

if [ -z "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]; then
  printf '%s: notifications are supported on macOS or over SSH\n' "${0##*/}" >&2
  exit 1
fi

# OSC 777 fields cannot safely contain terminal control characters. Replace
# newlines with spaces and strip the remaining C0 controls before emitting it.
title=$(printf '%s' "$title" | tr '\r\n\t;' '    ' | tr -d '\000-\010\013\014\016-\037\177')
message=$(printf '%s' "$message" | tr '\r\n\t;' '    ' | tr -d '\000-\010\013\014\016-\037\177')
osc=$(printf '\033]777;notify;%s;%s\007' "$title" "$message")

if [ -n "${TMUX-}" ]; then
  # tmux passthrough is a DCS sequence; every ESC in the payload is doubled.
  escaped_osc=${osc//$'\033'/$'\033\033'}
  notification=$(printf '\033Ptmux;%s\033\\' "$escaped_osc")
else
  notification=$osc
fi

if tty_path=$(tty 2>/dev/null) && [ -w "$tty_path" ]; then
  printf '%s' "$notification" > "$tty_path"
elif [ -n "${SSH_TTY-}" ] && [ -w "$SSH_TTY" ]; then
  printf '%s' "$notification" > "$SSH_TTY"
else
  printf '%s' "$notification" >&2
fi
