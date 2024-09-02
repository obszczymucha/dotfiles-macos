export TMUX_MESSAGE_FILE="$HOME/.tmux.message"
export TMUX_MESSAGES_FILE="$DOTFILES_DIR/.tmux.messages"

alias t=tmux
alias ta="t a"
alias tn="t new-session -d"
alias tmsg=tmux_message
alias cm="immutable_tmux cmus cmus cmus"

TMUX_MESSAGE_BRB_FILE="$HOME/.tmux.message.brb"

function back() {
  if [[ -f $TMUX_MESSAGE_BRB_FILE ]]; then
    mv "$TMUX_MESSAGE_BRB_FILE" "$TMUX_MESSAGE_FILE"
  else
    tmsg
  fi
}

function _tmux_message_brb() {
  if [[ ! -f $TMUX_MESSAGE_BRB_FILE ]]; then
    mv "$TMUX_MESSAGE_FILE" "$TMUX_MESSAGE_BRB_FILE"
  fi
}

function brb() {
  if [[ $# == 0 ]]; then
    _tmux_message_brb
    echo "Be right back..." > "$TMUX_MESSAGE_FILE"
  else
    _tmux_message_brb
    echo "BRB: $*" > "$TMUX_MESSAGE_FILE"
  fi
}

# shellcheck disable=2120
function tmux_message() {
  if [[ $# == 0 ]]; then
    shuf -n 1 "$TMUX_MESSAGES_FILE" > "$TMUX_MESSAGE_FILE"
  else
    echo "$@" > "$TMUX_MESSAGE_FILE"
  fi
}

function n() {
  tmux rename-window "$1"
}

function immutable_tmux() {
  if [[ $# != 3 ]]; then
    echo "immutable_tmux: 3 parameters required"
    return 1
  fi

  local session_name=$1
  local window_name=$2
  local cmd=$3


  if [[ -z $TMUX ]]; then
    if tmux attach-session -t "$session_name:$window_name" 2> /dev/null; then
      return
    fi
  else
    if tmux switch-client -t "$session_name:$window_name" 2> /dev/null; then
      return
    fi
  fi
  
  if [[ -z $TMUX ]]; then
    tmux new-session -s "$session_name" -n "$window_name" "$cmd"
  else
    if ! tmux has-session -t "$session_name" 2> /dev/null; then
      tmux new-session -s "$session_name" -n "$window_name" -d "$cmd"
      tmux switch-client -t "$session_name:$window_name"
    else
      tmux new-window -b -t "$session_name:" -n "$window_name" "$cmd"
      tmux switch-client -t "$session_name:$window_name"
    fi
  fi
}

function vc() {
  # shellcheck disable=2016
  immutable_tmux nvim-config code 'nvim +"cd $HOME/.config/nvim" +HarpoonFirst'
}

function vcc() {
  # shellcheck disable=2016
  tmux send-keys 'builtin cd "$HOME/.config/nvim"' Enter
  tm nvim-config
  tmux send-keys 'nvim +"HarpoonFirst"' Enter
}

function rc() {
  # shellcheck disable=2016
  immutable_tmux zshrc zshrc 'nvim ~/.dotfiles/current/.zshrc +"cd $ZSHRC_DIR" +HarpoonFirst'
}

function tm() {
  if [[ $# != 1 ]]; then
    echo "Usage: $0 <tmux_session_name>"
    return 1
  fi

  local session_name="$1"
  
  if tmux has-session -t "$session_name" > /dev/null 2>&1 ; then
    tmux switch-client -t "$session_name"
  else
    local window_count
    window_count=$(tmux list-windows | wc -l)

    local start_dir="$PWD"

    if [[ $window_count -eq 1 ]]; then
      tmux rename-session "$session_name"
      tmux rename-window "code"
      tmux new-window -d -n "shell" "NO_CD=1 $SHELL"
    else
      tmux new-session -d -s "$session_name" -n code "cd '$start_dir'; $SHELL"
      tmux new-window -t "$session_name:2" -n shell
      tmux select-window -t "${session_name}:1"
      tmux switch-client -t "$session_name"
    fi
  fi
}

if [[ -z $TMUX && -z $NO_TMUX && $USER != "root" ]]; then
  tmux_message
  exec tmux new-session -A
fi

