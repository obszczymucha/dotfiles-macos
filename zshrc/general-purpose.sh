export EDITOR=nvim
export PROJECTS_DIR="$HOME/src"
export ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"

alias browse="tree -d -L 2 -C"
alias c="clear"
alias hostname="cat /etc/hostname"
alias pwdp='pwd -P'
alias x=exit
alias gpgtty='export GPG_TTY=$TTY'
alias vrc='nvim ~/.zshrc +"cd $ZSHRC_DIR"'
alias ff="fastfetch"

alias v_="nvim -u NONE"
alias vt='v $HOME/.tmux.conf'
alias l > /dev/null && unalias l
alias l="gls -lh --group-directories-first --color"
alias ll > /dev/null && unalias ll
alias ll="gls -lah --group-directories-first --color"
alias la > /dev/null && unalias la
alias la=ll
alias cl="c && l"
alias cvc='cd ~/.config/nvim'
alias src="NO_TMUX=1 NO_CD=1 source ~/.zshrc"

function stow-dotfiles() {
  local pushed=false

  if [[ "$(pwd)" != "$DOTFILES_DIR" ]]; then
    pushd "$DOTFILES_DIR" > /dev/null || return
    pushed=true
  fi

  if [[ "$1" == "--cleanup" ]]; then
    stow -S -t "$HOME" . --adopt 2>&1 | stow-cleanup.sh "$HOME"
  else
    stow -S -t "$HOME" . --adopt
  fi

  if [[ "$pushed" == true ]]; then
    popd > /dev/null || return
  fi
} 

function renvim() {
  local nvim_share_dir="$HOME/.local/share/nvim"
  mv "${nvim_share_dir}/harpoon.json" /tmp/harpoon.json
  rm -rf "$nvim_share_dir"
  mkdir -p "$nvim_share_dir"
  mv /tmp/harpoon.json "${nvim_share_dir}/harpoon.json"
}

function v() {
  if [[ $# -eq 0 ]]; then
    nvim
  else
    nvim "$@"
  fi
}

function fn() {
  if [[ $# == 0 ]]; then return; fi
  local funcname="$1"
  local search_dir="$2"
  local full_path
  local line_number

  if [[ -z "$search_dir" ]]; then
    local builtin_type
    search_dir="$DOTFILES_DIR"
    builtin_type=$(builtin type "$funcname")

    local sed_expression="s/^${funcname} is a shell function from (.+)\$/\\1/g"
    full_path=$(echo "$builtin_type" | ggrep "is a shell function from" | gsed -E "$sed_expression")

    if [[ -z "$full_path" ]]; then
      if ! echo "$builtin_type" | ggrep "is an alias for" > /dev/null; then
        echo "$builtin_type"
        return
      fi

      local grep_expression="^alias ${funcname} *="
      # shellcheck disable=2046
      read -r full_path line_number <<< $(ggrep -nr "$grep_expression" "$search_dir" | head -n 1 | gsed -E 's/^(.+):([0-9]+):.*$/\1 \2/g')
    else
      line_number=$(ggrep -En "(^${funcname}\(\)| ${funcname}\(\))" "$full_path" | head -n 1 | gsed -E 's/^([0-9]+):.*$/\1/g')
    fi

    if [[ -z "$full_path" ]]; then
      echo "$builtin_type"
      return
    fi

    nvim +"$line_number" +"normal! zz" "$full_path"
    return
  fi

  local grep_expression="^alias ${funcname} *="
  # shellcheck disable=2046
  read -r full_path line_number <<< $(rg -n "$grep_expression" "$search_dir" | head -n 1 | gsed -E 's/^(.+):([0-9]+):.*$/\1 \2/g')

  if [[ -z "$full_path" ]]; then
    local grep_expression="^(${funcname}\(\)|function ${funcname}\(\))"
    # shellcheck disable=2046
    read -r full_path line_number <<< $(rg -En "$grep_expression" "$search_dir" | head -n 1 | gsed -E 's/^(.+):([0-9]+):.*$/\1 \2/g')
  fi

  if [[ -z "$full_path" ]]; then
    echo "$funcname not found."
    return
  fi

  nvim +"$line_number" +"normal! zz" "$full_path"
}

sourcex() {
  set -a; # shellcheck disable=SC1090
  source "$1"; set +a
}
