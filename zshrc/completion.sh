# shellcheck disable=SC2148,2296

export ZLE_REMOVE_SUFFIX_CHARS="" # Removes eating of "|" after tab completion.
export HISTSIZE=50000
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' '+l:|=* r:|=*'
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no
# zstyle ":fzf-tab:complete:cd:*" fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-smart-tab no # Disable fzf-tab tab key override.
zstyle ':fzf-tab:*' fzf-bindings 'alt-j:down' 'alt-k:up' 'tab:accept'

autoload -U compinit && compinit
compdef -d play

compdef _files chromium
compdef _files v
 
_git_add_files() {
    local IFS=$'\n'
    # shellcheck disable=SC2034,2207
    local files=($(git status --short | awk '{$1=""; sub(/^[ \t]+/, ""); print}'))
    _wanted files expl 'modified files' compadd -Q -a files
}

compdef _git_add_files ga
compdef _git_add_files gr
compdef _git_add_files gco
compdef _git_add_files gd

#bindkey -M menuselect 'h' vi-backward-char
#bindkey -M menuselect 'k' vi-up-line-or-history
#bindkey -M menuselect 'l' vi-forward-char
#bindkey -M menuselect 'j' vi-down-line-or-history

