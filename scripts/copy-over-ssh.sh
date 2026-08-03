#!/usr/bin/env bash
# Read from standard input, strip trailing newlines, encode to base64, and output OSC 52
text=$(cat)

# Check if running inside tmux to format the bypass sequence correctly
if [ -n "$TMUX" ]; then
  printf '%s' "$text" | tmux load-buffer -w -
else
  encoded=$(printf "%s" "$text" | base64 | tr -d '\n')
  printf "\e]52;c;%s\a" "$encoded" >/dev/tty
fi
