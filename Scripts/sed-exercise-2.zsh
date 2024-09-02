#!/usr/bin/env zsh
set -e
autoload colors; colors

# Fix me
SED_EXPRESSION="s/.*//g"

function insert_hic_into_sentence() {
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
  local f="insert_hic_into_sentence"
  echo "Testing function $f..."
  echo

  test $f "This is a test..." "This is a test (hic!)..."
  test $f "This is a test." "This is a test (hic!)."
  test $f "This is a test.." "This is a test (hic!).."
  test $f "This is a test" "This is a test (hic!)"
  test $f "This is a tes.t." "This is a tes.t (hic!)."
}

run

