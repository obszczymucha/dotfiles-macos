#!/usr/bin/env bash

main() {
  local dir=""

  if [[ -n "$1" ]]; then
    dir="$1/"
  fi

  grep -E "^[^:]+existing target is not owned by stow: .+" | sed 's/.*: \(.*\)/\1/' | xargs -I {} sh -c 'echo "Deleting: {}" && rm -rf "'"$dir"'{}"'
}

main "$@"
