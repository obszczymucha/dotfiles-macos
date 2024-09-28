#!/usr/bin/env bash

function main() {
  local min_length=10
  local max_height=20
  local width
  width=$(tmux list-sessions -F "#S" | awk -v min_length="$min_length" '{ if (length($0) > max) { max = length($0); longest = length($0) } } END { if (longest < min_length) { print min_length + 2 } else { print longest + 5 } }')

  local session_count
  session_count=$(tmux list-sessions -F "#S" | wc -l | xargs)
  local height=$((max_height + 4))

  if [[ "$session_count" -lt "$max_height" ]]; then
    height=$((session_count + 4))
  fi

  tmux display-popup -S "fg=#806aba" -T "Sessions" -w "$width" -h "$height" -E "$SCRIPTS_DIR/tmux_select_session.sh"
}

main "$@"

