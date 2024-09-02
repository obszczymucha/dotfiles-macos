AUTOLSIGNORE_FILE="$HOME/.autolsignore"

function autols() {
  touch "$AUTOLSIGNORE_FILE"
  local pwdp="$(pwdp)"

  if ! cat "$AUTOLSIGNORE_FILE" | grep -x "$pwdp" > /dev/null; then
    gls -lh --group-directories-first --color
  fi
}

function al() {
  touch "$AUTOLSIGNORE_FILE"
  local pwdp="$(pwdp)"

  if cat "$AUTOLSIGNORE_FILE" | grep -x "$pwdp" > /dev/null; then
    sed -iE "\|^${pwdp}$|d" "$AUTOLSIGNORE_FILE"
    echo "[autols] Unignored."
  else
    echo "$pwdp" >> "$AUTOLSIGNORE_FILE"
    echo "[autols] Ignored."
  fi
}

