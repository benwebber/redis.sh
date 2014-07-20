#!/bin/bash
#
# redis.sh
# Bash library for interacting with Redis.
#
# Copyright 2014 Ben Webber <benjamin.webber@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

# Print debug statements.
# Arguments:
#   $@  strings to print
# Returns:
#   debug statement
debug() {
  [[ $DEBUG -eq 1 ]] && echo "DEBUG ${@}"
}

# Strip carriage returns from strings. RESP is a network protocol, and as such
# all responses terminate in CRLF.
# Arguments:
#   $1  string
# Returns:
#   String without CR
strip_cr() {
  local string="${1}"
  echo "${string%}"
}

# Open connection to the Redis instance.
# Arguments:
#   None
# Returns:
#   None
redis::__setup() {
  : ${REDIS_HOSTNAME:='localhost'}
  : ${REDIS_PORT:=6379}
  debug "opening Redis connection to ${REDIS_HOSTNAME}:${REDIS_PORT}"
  exec 9<>/dev/tcp/$REDIS_HOSTNAME/$REDIS_PORT
  debug "opened Redis connection on FD 9"
}

# Close file descriptor.
# Arguments:
#   None
# Returns:
#   None
redis::__teardown() {
  debug "closing Redis connection on FD 9"
  exec 9<&-
  exec 9>&-
  debug 'closed Redis connection'
}

# Construct a RESP command according to the Redis Protocol specification
# (<http://redis.io/topics/protocol>).
# Arguments:
#   $@  command to run
# Returns:
#   RESP-formatted command
redis::__construct_request() {
  local cmd="*${#}\r\n"
  for arg in "${@}"; do
    local fragment="\$${#arg}\r\n${arg}\r\n"
    cmd="${cmd}${fragment}"
  done
  echo "${cmd}"
}

# Send a request by writing to the TCP socket.
# Arguments:
#   $1  RESP-formatted command
# Returns:
#   None
redis::__send() {
  debug "sending command to Redis instance"
  echo -e "${1}" >&9
  debug 'sent command'
}

redis::__parse_simple_response() {
  local response="${1}"
  local header="${2}"
  response="${response#${header}}"
  response=$(strip_cr "${response}")
  echo "${response}"
}

redis::__parse_simple_string() {
  local response="${1}"
  echo $(redis::__parse_simple_response "${response}" "+")
}

redis::__parse_integer() {
  local response="${1}"
  echo $(redis::__parse_simple_response "${response}" ":")
}

redis::__parse_error() {
  local response="${1}"
  echo $(redis::__parse_simple_response "${response}" "-")
}

# Parse a RESP response.
# Arguments:
#   $1  RESP-formatted response
# Returns:
#   Data represented by response
redis::__parse_response() {
  local response=$1
  debug "response header: ${response}"
  case $response in
    # Simple String
    +*)
      debug "response is a Simple String"
      redis::__parse_simple_string "${response}"
      ;;
    # Error
    -*)
      debug "response is an Error"
      redis::__parse_error "${response}"
      ;;
    # Integer
    :*)
      debug "response is an Integer"
      redis::__parse_integer "${response}"
      ;;
    # Null Bulk String
    \$-1*)
      # From the Redis Protocol specification, "The client library API should
      # not return an empty string, but a nil object, when the server replies
      # with a Null Bulk String."
      #
      # Bash does not distinguish between null values and empty strings, so we
      # will return a special string.
      #
      # TODO: Switch this to returning an empty string, but a reserved exit
      # code.
      debug "received null bulk string"
      echo '(nil)'
      ;;
    # Bulk String
    \$*)
      # Strip initial $ and CR from length header.
      local length="${response#\$}"
      length="${length%}"
      debug "response is a Bulk String of length ${length}"
      debug "reading ${length} bytes from response"
      # Read in value. Do not break on newlines.
      IFS=
      read -N $length -u 9 bulk
      echo "${bulk}"
      ;;
    # Null Array
    \*-1*)
      debug "response is an Null Array"
      echo '(nil)'
      ;;
    # Array
    \**)
      local result=()
      local length=$(strip_cr "${response#\*}")
      debug "response is an Array of length ${length}"
      # Parse the array response recursively.
      # TODO: Fix for loop. It should only need to decrement to 0 and should
      # not capture blank lines.
      for ((i=$length; i >= -1; i--)); do
        read -u 9 line
        local element=$(redis::__parse_response $line)
        result+=("${element}")
      done
      echo "${result[@]}"
      ;;
    # Unhandled
    *)
      echo "${response}"
      ;;
  esac
}

# Run arbitrary commands against a Redis instance.
# Arguments:
#   $1      Redis instance URL
#   ${@:1}  command to run
# Returns:
#   None
redis::redis() {
  redis::__setup
  # Debug statements must be outside redis::__construct_request() or they will
  # be captured.
  debug "Received command: ${@}"
  # Pass in arguments in quotes to avoid internal splitting.
  request=$(redis::__construct_request "${@}")
  debug "Formatted command as RESP: ${request}"
  redis::__send "${request}"
  read -r -u 9 response
  redis::__parse_response "${response}"
  redis::__teardown
}
