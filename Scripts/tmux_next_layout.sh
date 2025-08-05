#!/usr/bin/env bash

current_layout=$(tmux display-message -p '#{window_layout}')

if [[ "$current_layout" == *"{"* ]]; then
  tmux set-option @saved_horizontal_layout "$current_layout"
  saved_layout=$(tmux show-option -v @saved_vertical_layout 2>/dev/null)
  tmux select-layout "${saved_layout:-even-vertical}"
elif [[ "$current_layout" == *"["* ]]; then
  tmux set-option @saved_vertical_layout "$current_layout"
  saved_layout=$(tmux show-option -v @saved_horizontal_layout 2>/dev/null)
  tmux select-layout "${saved_layout:-even-horizontal}"
else
  tmux select-layout "even-vertical"
fi

