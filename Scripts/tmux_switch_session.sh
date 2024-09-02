#!/usr/bin/env bash

main() {
  local direction="$1"
  local sessions
  sessions=$(tmux list-sessions -F '#{session_created} #{session_name}' | sort -n | awk '{print $2}')

  local current_session
  current_session=$(tmux display-message -p '#{session_name}')

  local current_index
  current_index=$(echo "$sessions" | grep -n "^$current_session$" | cut -d: -f1)

  local session_count
  session_count=$(echo "$sessions" | wc -l)

  if [ "$direction" == "prev" ]; then
    next_index=$((current_index - 1))
    if [ "$next_index" -lt 1 ]; then next_index="$session_count"; fi
  else
    next_index=$((current_index + 1))
    if [ "$next_index" -gt "$session_count" ]; then next_index=1; fi
  fi

  next_session=$(echo "$sessions" | sed -n "${next_index}p")

  if [ -n "$next_session" ]; then
    tmux switch-client -t "$next_session"
  fi
}

main "$@"

