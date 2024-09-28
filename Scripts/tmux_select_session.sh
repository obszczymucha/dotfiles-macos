#!/usr/bin/env bash

function main() {
  local session_name
  session_name=$(tmux list-sessions -F "#{session_name}" | fzf)

  if [[ -z "$session_name" ]]; then
    return
  fi

  tmux switch-client -t "$session_name"
}

main "$@"

