#!/usr/bin/env bash

window_exists() {
  local window_list
  window_list=$(tmux list-windows -F '#{window_name}')

  for window_name in $window_list; do
    if [[ "$window_name" == "$1" ]]; then
      return 0;
    fi
  done

  return 1
}

window_has_two_panes() {
  local pane_count
  pane_count=$(tmux list-panes -t "$1" -F '#{pane_id}' | wc -l)

  [[ "$pane_count" -eq 2 ]] && return 0 || return 1
}

main() {
  if window_exists "code" && window_has_two_panes "code"; then
    tmux select-pane -t 2\; break-pane -n shell\; select-window -t code
    return 0
  fi

  if window_exists "code" && window_exists "shell"; then
    local layout
    layout=$(tmux show-option -gqv "@code-with-shell-layout")
    tmux join-pane -t code -s shell\; select-layout "$layout"
    return 0
  fi
}

main

