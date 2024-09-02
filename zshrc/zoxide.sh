eval "$(zoxide init --cmd j --hook pwd zsh)"

function j() {
  __zoxide_z "$@"
  autols
  pwd > "$LAST_DIRECTORY_FILE"
}
