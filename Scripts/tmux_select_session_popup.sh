#!/usr/bin/env bash

function main() {
  local min_length=10
  local max_height=25
  local width
  width=$(tmux list-sessions -F "#S" | awk -v min_length="$min_length" '{ if (length($0) > max) { max = length($0); longest = length($0) } } END { if (longest < min_length) { print min_length + 2 } else { print longest + 5 } }')

  local session_count
  session_count=$(tmux list-sessions -F "#S" | wc -l | xargs)

  if [[ "$session_count" -eq 1 ]]; then
    return
  fi

  local current_session
  current_session=$(tmux display-message -p "#S")

  if [[ "$session_count" -eq 2 ]]; then
    local other_session
    other_session=$(tmux list-sessions -F "#S" | grep -v "^$current_session\$")

    tmux switch-client -t "$other_session"
    return
  fi

  local height=$((max_height + 3))

  if [[ "$session_count" -lt "$max_height" ]]; then
    height=$((session_count + 3))
  fi

  tmux display-popup -S "fg=#806aba" -T "Sessions" -w "$width" -h "$height" -E "$SCRIPTS_DIR/tmux_select_session.sh $current_session"
}

main "$@"

