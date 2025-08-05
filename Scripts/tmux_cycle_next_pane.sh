#!/usr/bin/env bash

window_count() {
  tmux list-windows | wc -l | xargs
}

pane_count() {
  tmux list-panes | wc -l | xargs
}

window_has_two_panes() {
  local pane_count
  pane_count=$(tmux list-panes -t "$1" -F '#{pane_id}' | wc -l)

  [[ "$pane_count" -eq 2 ]] && return 0 || return 1
}

main() {
  local opt="$1"
  local opt2="$2"

  local windows
  windows=$(window_count)
  local panes
  panes=$(pane_count)

  if [[ "$windows" -eq 1 && "$panes" -eq 1 ]]; then
    return
  fi

  local window_name
  window_name=$(tmux show-option -q @window-name | awk '{print $2}')

  if [[ "$panes" -gt 1 ]]; then
    if [[ -n "$window_name" && "$window_name" != "" ]]; then
      tmux break-pane -s 2 -d -a -n "$window_name"
      tmux set-option -u @window-name
    else
      tmux break-pane -s 2 -d -a
    fi

    return
  fi

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  if [[ "$current_window_index" == "$windows" ]]; then
    return
  fi

  local next_window_index
  next_window_index=$((current_window_index + 1))

  if [[ "$next_window_index" -gt "$windows" ]]; then
    return
  fi

  window_name=$(tmux display-message -p -t "$next_window_index" '#{window_name}')
  tmux set-option @window-name "$window_name"

  if [[ "$opt" == "h" ]]; then
    tmux join-pane -s "$next_window_index" -h ${opt2:+-l "$opt2"}
  else
    tmux join-pane -s "$next_window_index" -v ${opt2:+-l "$opt2"}
  fi
}

main "$@"

