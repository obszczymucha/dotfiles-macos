#!/usr/bin/env zsh
set -e
autoload colors; colors

# Fix me
SED_EXPRESSION="s/(.*)/\1!/g"

function replace_dots_with_exclamation_mark() {
  echo $1 | sed -E $SED_EXPRESSION
}

function test() {
  local func=$1
  local input=$2
  local expected=$3
  local was=$($func $input)

  echo "Input: $input"
  echo "Expected: $expected"
  echo "Was: $was"

  if [[ $expected == $was ]]; then
    echo "Test $fg_bold[green]PASSED"
  else
    echo "Test $fg_bold[red]FAILED"
  fi

  echo $reset_color
}

function run() {
  local f="replace_dots_with_exclamation_mark"
  echo "Testing function $f..."
  echo

  test $f "This is a test..." "This is a test!"
  test $f "This is a test." "This is a test!"
  test $f "This is a test.." "This is a test!"
  test $f "This is a test" "This is a test!"
  test $f "This is a tes.t." "This is a tes.t!"
}

run

