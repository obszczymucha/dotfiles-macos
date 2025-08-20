#!/usr/bin/env bash

COMMAND="source ~/src/lua/dotfiles/zshrc/work.sh && genai && poff && claude"

count_panes() {
  tmux list-panes | wc -l
}

main() {
  local opt="$1"
  local opt2="$2"

  local current_window
  current_window=$(tmux display-message -p '#W')

  if [[ "$current_window" == "claude" ]]; then
    exit 0
  fi

  if tmux list-windows -F '#W' | grep -q "^claude$"; then
    tmux select-window -t claude
  else
    tmux set-option @window-name "claude"

    local current_path
    current_path=$(tmux display-message -p "#{pane_current_path}")

    if [[ "$opt" == "h" ]]; then
      tmux split-window -h -c "$current_path" ${opt2:+-l "$opt2"} "$COMMAND $3"
    else
      tmux split-window -v -c "$current_path" ${opt2:+-l "$opt2"} "$COMMAND $3"
    fi

    local pane_count
    pane_count=$(count_panes)
    tmux set -p -t "${current_window}.${pane_count}" @window-name "claude"
  fi
}

main "$@"

