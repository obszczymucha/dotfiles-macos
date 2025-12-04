AUTOLSIGNORE_FILE="$HOME/.autolsignore"

function autols() {
  [[ -z "$AUTOLSIGNORE_FILE" ]] && return
  touch "$AUTOLSIGNORE_FILE"
  local pwdp
  pwdp="$(pwd -P)"

  if ! grep -x "$pwdp" "$AUTOLSIGNORE_FILE" > /dev/null; then
    gls -lh --group-directories-first --color | gsed '1{/^total/d}'
  fi
}

function al() {
  [[ -z "$AUTOLSIGNORE_FILE" ]] && return
  touch "$AUTOLSIGNORE_FILE"
  local pwdp
  pwdp="$(pwd -P)"

  if grep -x "$pwdp" "$AUTOLSIGNORE_FILE" > /dev/null; then
    sed -iE "\|^${pwdp}$|d" "$AUTOLSIGNORE_FILE"
    echo "[autols] Unignored."
  else
    echo "$pwdp" >> "$AUTOLSIGNORE_FILE"
    echo "[autols] Ignored."
  fi
}

