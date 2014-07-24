#!/bin/bash
#
# Generate test skeletons for Redis commands.

COMMAND_GROUPS=(
  'connection'
  'generic'
  'hash'
  'hyperloglog'
  'list'
  'pubsub'
  'scripting'
  'server'
  'set'
  'sorted_set'
  'string'
  'transactions'
)

header() {
  cat<<EOF
# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for ${1} commands

load test_helper

${2}
EOF
}

main() {
  for g in "${COMMAND_GROUPS[@]}"; do
    tests=$(python generator.py -g ${g} -t test ${1})
    script=$(header ${g} "${tests}")
    echo "${script}" > ${g}.bats
  done
}

main "${@}"
