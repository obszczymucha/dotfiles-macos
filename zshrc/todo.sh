export TODO_FILE="$HOME/.TODO"
alias etodo='v $TODO_FILE'

function todo() {
  if [[ ! -f "$TODO_FILE" || ! -s "$TODO_FILE" ]]; then
    return
  fi

  print -P "%F{white}TODO:%f"

  while IFS= read -r line; do
    print -P "$line"
  done < <(sed -E 's/^(.*)$/ %F{magenta}\*%f \1/g' "$TODO_FILE")

  echo
}

todo
