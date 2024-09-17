#!/usr/bin/env bash

function configure() {
  defaults write -app "$1" NSUserKeyEquivalents "$(cat "$2")"
}

function configure_all() {
  defaults write -g NSUserKeyEquivalents "$(cat global.conf)"
  configure "Alacritty" alacritty.conf
  configure "Google Chrome" chrome.conf
  configure "Microsoft Teams" teams.conf
  configure "Microsoft Outlook" outlook.conf
  configure "IntelliJ IDEA CE" intellij.conf
}

function main() {
  if [[ $# != 2 ]]; then
    configure_all
  else
    configure "$1" "$2"
  fi
}

main "$@"

