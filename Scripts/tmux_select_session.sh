#!/usr/bin/env bash

function main() {
  local session_name
  session_name=$(tmux list-sessions -F "#{session_name}" | fzf --bind=alt-q:close,alt-j:down,alt-k:up,tab:accept --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a --multi)

  if [[ -z "$session_name" ]]; then
    return
  fi

  tmux switch-client -t "$session_name"
}

main "$@"

