#!/bin/bash

. "${BATS_TEST_DIRNAME}/../redis.sh"

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------

setup() {
  redis-cli FLUSHALL
}

fail() {
  echo "$@"
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    fail "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    fail "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    echo "expected: $2"
    echo "actual:   $1"
    fail
  fi
}

assert_ok() {
  assert_equal "$1" "OK"
}

assert_error() {
  assert_equal "${1:0:3}" "ERR"
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    fail "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      fail "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        fail "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    fail "failed: $@"
  fi
}
