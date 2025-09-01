#!/usr/bin/env bash

main() {
  tmux if-shell -F '#{&&:#{>:#I,1},#{==:#{window_panes},1}}' "join-pane -h -s .1 -t '{previous}.-1'"
}

main "$@"

