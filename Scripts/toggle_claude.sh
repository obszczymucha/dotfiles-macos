#!/usr/bin/env bash

COMMAND="claude"

count_panes() {
  tmux list-panes | wc -l
}

calculate_split_size() {
  local left_size="$1"
  if [[ "$left_size" == *% ]]; then
    local percent=${left_size%\%}
    echo "$((100 - percent))%"
  else
    echo $((100 - left_size))
  fi
}

window_exists() {
  tmux list-windows -F '#{window_name}' | grep -qx "$1"
}

is_any_pane_the_window() {
  tmux list-panes -F '#{@window-name}' | grep -qx "$1"
}

break_pane() {
  local pane="{bottom-right}"
  local new_window_name
  new_window_name=$(tmux show-option -p -t "$pane" -v @window-name)

  if [[ -z "$new_window_name" ]]; then
    new_window_name="win_$((RANDOM % 100))"
  fi

  tmux break-pane -s "$pane" -d -a -n "$new_window_name"

  local pane_count_after
  pane_count_after=$(tmux display-message -p '#{window_panes}')

  if [[ "$pane_count_after" -eq 1 ]]; then
    local remaining_name
    remaining_name=$(tmux show-option -p -t 1 -qv @window-name)
    if [[ -n "$remaining_name" ]]; then
      tmux rename-window "$remaining_name"
    fi
  fi
}

main() {
  local opt="$1"
  local left_size="$2"
  local extra_args="$3"

  local current_window
  current_window=$(tmux display-message -p '#W')

  if [[ "$current_window" == "claude" ]]; then
    exit 0
  fi

  local pane_count
  pane_count=$(count_panes)

  local new_split_size=""
  if [[ -n "$left_size" && "$left_size" != "--" ]]; then
    new_split_size=$(calculate_split_size "$left_size")
  fi

  # Already split with claude — nothing to do
  if [[ "$pane_count" -gt 1 ]] && is_any_pane_the_window "claude"; then
    exit 0
  fi

  # Split exists but is not claude — capture its size, then break it out
  if [[ "$pane_count" -gt 1 ]]; then
    if [[ "$opt" == "h" ]]; then
      new_split_size=$(tmux display-message -p -t '{bottom-right}' '#{pane_width}')
    else
      new_split_size=$(tmux display-message -p -t '{bottom-right}' '#{pane_height}')
    fi
    break_pane
    pane_count=$(count_panes)
  fi

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  # Claude window exists — join it into the current window
  if window_exists "claude"; then
    if [[ "$opt" == "h" ]]; then
      tmux join-pane -s "claude.1" -t "${current_window_index}.${pane_count}" -h ${new_split_size:+-l "$new_split_size"}
    else
      tmux join-pane -s "claude.1" -t "${current_window_index}.${pane_count}" -v ${new_split_size:+-l "$new_split_size"}
    fi
    return
  fi

  # No claude window — create a new split and run claude
  local current_path
  current_path=$(tmux display-message -p "#{pane_current_path}")

  if [[ "$opt" == "h" ]]; then
    tmux split-window -h -d -c "$current_path" ${new_split_size:+-l "$new_split_size"} "$COMMAND $extra_args"
  else
    tmux split-window -v -d -c "$current_path" ${new_split_size:+-l "$new_split_size"} "$COMMAND $extra_args"
  fi

  pane_count=$(count_panes)
  tmux set -p -t "${current_window}.${pane_count}" @window-name "claude"
}

main "$@"

