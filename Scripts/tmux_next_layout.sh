#!/usr/bin/env bash

function get_next_layout() {
  if [[ "$1" == *"{"* ]]; then
    echo "even-vertical"
  elif [[ "$1" == *"["* ]]; then
    echo "even-horizontal"
  else
    echo "even-vertical"
  fi
}

function main() {
  local current_layout
  current_layout=$(tmux display-message -p '#{window_layout}')
  local next_layout
  next_layout=$(get_next_layout "$current_layout")

  tmux select-layout "$next_layout"
}

main "$@"

