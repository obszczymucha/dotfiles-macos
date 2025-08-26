#!/usr/bin/env bash

count_windows() {
  tmux list-windows | wc -l
}

count_panes() {
  tmux list-panes | wc -l
}

random_name() {
  echo "win_$((RANDOM % 100))"
}

window_exists() {
  local window_list
  window_list=$(tmux list-windows -F '#{window_name}')

  for window_name in $window_list; do
    if [[ "$window_name" == "$1" ]]; then
      return 0
    fi
  done

  return 1
}

break_pane() {
  local pane_count="$1"
  local window_name
  window_name=$(tmux show-option -p -t "$pane_count" -v @window-name)

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  if [[ -n "$window_name" && "$window_name" != "" ]]; then
    # local last_window_index
    # last_window_index=$(tmux show-option -q -p -t "${current_window_index}.${pane_count}" -v @last-window-index)
    # last_window_index=$((last_window_index - 1))

    tmux break-pane -s "$pane_count" -d -a -n "$window_name" ${last_window_index:+-t ":$last_window_index"}
  else
    local new_name
    new_name=$(random_name)
    tmux break-pane -s "$pane_count" -d -a -n "$new_name"
  fi

  local current_window_pane_count
  current_window_pane_count=$(tmux display-message -p '#{window_panes}')

  if [[ "$current_window_pane_count" -eq 1 ]]; then
    local window_name
    window_name=$(tmux show-option -p -t 1 -qv @window-name)

    if [[ -n "$window_name" && "$window_name" != "" ]]; then
      tmux rename-window -t "${current_window_index}" "$window_name"
    else
      local new_name
      new_name=$(random_name)
      tmux rename-window -t "${current_window_index}" "$new_name"
      tmux set-option -p -t ".1" @window-name "$new_name"
    fi
  fi
}

create_window() {
  local window_name="$1"
  tmux new-window -d -e NO_CD=1 -c "#{pane_current_path}" -n "$window_name"
  tmux set -p -t "${window_name}.1" @window-name "$window_name"
}

swap_pane() {
  local window_name="$1"
  local pane_count="$2" # unused?
  local swap_window_name="$3"

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  local this_window_name
  this_window_name=$(tmux show-option -p -t "${current_window_index}.2" -v @window-name)

  local that_window_name
  that_window_name=$(tmux show-option -p -t "${swap_window_name}.1" -v @window-name)

  tmux swap-pane -s "${current_window_index}.2" -t "${swap_window_name}.1"
  tmux set -p -t "${swap_window_name}.1" @window-name "$this_window_name"
  tmux set -p -t "${current_window_index}.2" @window-name "$that_window_name"
  tmux rename-window -t "${swap_window_name}" "$this_window_name"
}

join_pane() {
  local pane_count="$1"
  local new_split_size="$2"
  local swap_window_name="$3"
  local orientation="$4"
  local params="$5"

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  if [[ "$new_split_size" == "--" ]]; then
    new_split_size=""
  else
    if [[ "$new_split_size" == *% ]]; then
      local percent=${new_split_size%\%}
      local complement
      complement=$((100 - percent))
      new_split_size="${complement}%"
    else
      new_split_size=$((100 - new_split_size))
    fi
  fi

  local current_window_index
  swap_window_index=$(tmux display-message -t "${swap_window_name}" -p '#{window_index}')

  # tmux set -p -t "${swap_window_name}.1" @last-window-index "$swap_window_index"

  if [[ "$orientation" == "h" ]]; then
    tmux join-pane ${params:+"$params"} -s "${swap_window_name}.1" -t "${current_window_index}.${pane_count}" -h ${new_split_size:+-l "$new_split_size"}
  else
    tmux join-pane ${params:+"$params"} -s "${swap_window_name}.1" -t "${current_window_index}.${pane_count}" -v ${new_split_size:+-l "$new_split_size"}
  fi

  if tmux list-windows -f "#{==:#W,${swap_window_name}}" -F '#W' | grep -q .; then
    local new_window_name
    new_window_name=$(tmux show-option -p -t "${swap_window_name}.1" -qv @window-name)

    if [[ -n "$new_window_name" && "$new_window_name" != "" ]]; then
      tmux rename-window -t "${swap_window_name}" "$new_window_name"
    else
      local new_name
      new_name=$(random_name)
      tmux rename-window -t "${swap_window_name}" "$new_name"
    fi
  fi

  # local new_pane_count
  # new_pane_count=$(count_panes)

  # tmux select-pane -t "$new_pane_count"
}

join_next_pane() {
  local window_count="$1"
  local pane_count="$2"
  local new_split_size="$3"
  local orientation="$4"

  local current_window_index
  current_window_index=$(tmux display-message -p '#{window_index}')

  if [[ "$current_window_index" == "$window_count" ]]; then
    return
  fi

  local next_window_index
  next_window_index=$((current_window_index + 1))

  if [[ "$next_window_index" -gt "$window_count" ]]; then
    return
  fi

  window_name=$(tmux display-message -p -t "$next_window_index" '#{window_name}')

  if [[ "$new_split_size" == "--" ]]; then
    new_split_size=""
  fi

  if [[ "$orientation" == "h" ]]; then
    tmux join-pane -d -s "${next_window_index}.1" -t "${current_window_index}.${pane_count}" -h ${new_split_size:+-l "$new_split_size"}
  else
    tmux join-pane -d -s "${next_window_index}.1" -t "${current_window_index}.${pane_count}" -v ${new_split_size:+-l "$new_split_size"}
  fi
}

is_any_pane_the_window() {
  local swap_window_name="$1"

  if tmux list-panes -F '#{@window-name}' | grep "$swap_window_name" >/dev/null; then
    return 0
  else
    return 1
  fi
}

main() {
  local orientation="$1" # h or v
  local new_split_size="$2" # horizontal or vertical (will split in half if not provided)
  local swap_window_name="$3"
  local params="$4"

  local window_count
  window_count=$(count_windows)
  local pane_count
  pane_count=$(count_panes)

  if [[ -z "$swap_window_name" ]]; then
    if [[ "$window_count" -eq 1 && "$pane_count" -eq 1 ]]; then
      return
    fi

    if [[ "$pane_count" -gt 1 ]]; then
      break_pane "$pane_count"
      return
    fi

    join_next_pane "$window_count" "$pane_count" "$new_split_size" "$orientation"
    return
  fi

  local current_window_name
  current_window_name=$(tmux display-message -p '#W')

  if [[ "$swap_window_name" == "$current_window_name" ]]; then
    return
  fi

  if [[ "$pane_count" -gt 1 ]] && is_any_pane_the_window "$swap_window_name"; then
    break_pane "$pane_count"
    return
  fi

  if ! window_exists "$swap_window_name"; then
    create_window "$swap_window_name"
  fi

  if [[ "$pane_count" -gt 1 ]]; then
    swap_pane "$window_name" "$pane_count" "$swap_window_name"
    return
  fi

  join_pane "$pane_count" "$new_split_size" "$swap_window_name" "$orientation" "$params"
  return
}

main "$@"

