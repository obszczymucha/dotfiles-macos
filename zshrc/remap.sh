bindkey -e
bindkey -r '^[' # by default this enables vi mode and fucks the other bindings up
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^[i' history-search-forward
bindkey '^[o' history-search-backward
#bindkey '^[j' down-line-or-search
#bindkey '^[k' up-line-or-search
bindkey '^[h' backward-char
bindkey '^[l' forward-char
bindkey '^[w' forward-word
bindkey '^[0' beginning-of-line
bindkey '^[4' end-of-line
bindkey '^[u' undo
bindkey '^[x' delete-char
bindkey '^[c' kill-line
bindkey '^[D' backward-kill-word
bindkey '^[X' backward-delete-char

_backward-kill-path-component() {
  # shellcheck disable=2034
  local WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
  zle backward-kill-word
}

zle -N _backward-kill-path-component
bindkey '^[S' _backward-kill-path-component

