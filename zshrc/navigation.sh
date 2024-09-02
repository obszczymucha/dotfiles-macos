source "$ZSHRC_DIR/autols.sh"

DIRJUMP_DIRECTORY=~/.dirjump
mkdir -p "$DIRJUMP_DIRECTORY"
MAIN_DIRECTORY_FILE="$DIRJUMP_DIRECTORY"/main
LAST_DIRECTORY_FILE="$DIRJUMP_DIRECTORY"/last
SECONDARY_DIRECTORY_FILE="$DIRJUMP_DIRECTORY"/secondary

function _m() {
  local FILE="$1"

  function set_dir() {
    pwd > "$FILE"
    pwd
  }

  if [[ $2 == "set" || ! -f "$FILE" ]]; then
    set_dir
    return
  fi

  local directory
  directory=$(cat "$FILE")

  if [[ $(pwd) == "$directory" ]]; then
    if [[ $# -gt 2 ]]; then
      cd "$3" || return
    fi

    return
  fi

  pwd > "$LAST_DIRECTORY_FILE"
  cd "$directory" || return

  if [[ $# -gt 2 ]]; then
    cd "$3" || return
  fi
}

function m() {
  _m "$MAIN_DIRECTORY_FILE"
}

function ms() {
  _m "$MAIN_DIRECTORY_FILE" set
}

function mm() {
  _m "$SECONDARY_DIRECTORY_FILE"
}

function mms() {
  _m "$SECONDARY_DIRECTORY_FILE" set
}

function mb() {
  if [[ -f "$LAST_DIRECTORY_FILE" ]]; then
    local tmp
    tmp="$(pwd)"
    local last_directory
    last_directory=$(cat "$LAST_DIRECTORY_FILE")
    cd "$last_directory" || return
    echo "$tmp" > "$LAST_DIRECTORY_FILE"
  fi
}

alias b=popd

function bb() {
  # shellcheck disable=2154
  if [[ ${#dirstack[@]} == 0 ]]; then
    mb
  else
    cd - || return
    pwd > "$LAST_DIRECTORY_FILE"
  fi
}

export DIRSTACKSIZE=8
setopt autopushd pushdminus pushdsilent pushdtohome
alias dh='dirs -v'

function cd() {
  local error
  error=$(builtin cd "$@" 2>&1 > /dev/null || return)
  local result=$?

  if [[ ! $result == "0" ]]; then
    # shellcheck disable=2001
    echo "$error" | sed -E 's/^cd:cd:[^:]+: //g' | sed -E 's/^(.)/\U\1/' >&2
    return $result
  else
    builtin cd "$@" || return
    autols
    pwd > "$LAST_DIRECTORY_FILE"
  fi
}

alias p='cd $HOME/src'

function jt() {
  if [[ $# == 0 ]]; then
    echo "Usage: jt <directory>" >&2
    return 1
  fi

  j "$@" && tm "$1"
}
