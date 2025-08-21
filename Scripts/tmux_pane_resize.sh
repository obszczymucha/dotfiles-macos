#!/usr/bin/env bash

count_panes() {
  tmux list-panes | wc -l
}

first_pane_size() {
  local pane=1
  local pane_width pane_height window_width window_height
  pane_width=$(tmux list-panes -F "#{pane_index} #{pane_width}" | awk -v p="$pane" '$1==p {print $2}')
  pane_height=$(tmux list-panes -F "#{pane_index} #{pane_height}" | awk -v p="$pane" '$1==p {print $2}')
  window_width=$(tmux display-message -p "#{window_width}")
  window_height=$(tmux display-message -p "#{window_height}")
  
  if [[ "$pane_width" == "$window_width" ]]; then
    awk "BEGIN {printf \"%.0f\", $pane_height*100/$window_height}"
  elif [[ "$pane_height" == "$window_height" ]]; then
    awk "BEGIN {printf \"%.0f\", $pane_width*100/$window_width}"
  else
    local pane1_height pane2_height
    pane1_height=$(tmux list-panes -F "#{pane_index} #{pane_height}" | awk '$1==1 {print $2}')
    pane2_height=$(tmux list-panes -F "#{pane_index} #{pane_height}" | awk '$1==2 {print $2}')
    
    if [[ "$pane1_height" == "$pane2_height" ]]; then
      awk "BEGIN {printf \"%.0f\", $pane_width*100/$window_width}"
    else
      awk "BEGIN {printf \"%.0f\", $pane_height*100/$window_height}"
    fi
  fi
}

resize_pane() {
  local pane_index="$1"
  local size="$2"
  tmux resize-pane -t "$pane_index" -x "${size}%" -y "${size}%"
}

main() {
  local adjustment="$1" # + or -
  
  local pane_count
  pane_count=$(count_panes)

  if [[ "$pane_count" -eq 1 ]]; then
    return
  fi

  local size
  size=$(first_pane_size)

  if [[ "$size" -lt 50 ]]; then
    if [[ "$adjustment" == "-" ]]; then
      return
    fi

    resize_pane 1 50
    return
  fi

  if [[ "$size" -eq 50 && "$adjustment" == "-" ]]; then
    return
  fi

  local margin
  margin=$(tmux show-option -gv @horizontal-split-margin | sed 's/%//')

  if [[ "$adjustment" == "-" && "$size" -le "$margin" ]]; then
    resize_pane 1 50
    return
  elif [[ "$adjustment" == "+" && "$size" -lt "$margin" ]]; then
    resize_pane 1 "$margin"
    return
  elif [[ "$adjustment" == "-" && "$size" -gt "$margin" ]]; then
    resize_pane 1 "$margin"
    return
  elif [[ "$adjustment" == "+" && "$size" -ge "$margin" ]]; then
    echo "split" >&2
    return
  fi
}

main "$@"

