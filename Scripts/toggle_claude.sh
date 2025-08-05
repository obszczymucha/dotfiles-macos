#!/usr/bin/env bash

main() {
  local opt="$1"
  local opt2="$2"
  
  current_window=$(tmux display-message -p '#W')
  
  if [[ "$current_window" == "claude" ]]; then
    exit 0
  fi
  
  if tmux list-windows -F '#W' | grep -q "^claude$"; then
    tmux select-window -t claude
  else
    tmux set-option @window-name "claude"
    
    if [[ "$opt" == "h" ]]; then
      tmux split-window -h ${opt2:+-l "$opt2"} claude
    else
      tmux split-window -v ${opt2:+-l "$opt2"} claude
    fi
  fi
}

main "$@"

