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

#-------------------------------------------------------------------------------
# Generic commands
#-------------------------------------------------------------------------------

# Delete a key
redis::del() {
  redis::redis 'DEL' "${@:1}"
}

# Return a serialized version of the value stored at the specified key.
redis::dump() {
  redis::redis 'DUMP' "${@:1}"
}

# Determine if a key exists
redis::exists() {
  redis::redis 'EXISTS' "${@:1}"
}

# Set a key's time to live in seconds
redis::expire() {
  redis::redis 'EXPIRE' "${@:1}"
}

# Set the expiration for a key as a UNIX timestamp
redis::expireat() {
  redis::redis 'EXPIREAT' "${@:1}"
}

# Find all keys matching the given pattern
redis::keys() {
  redis::redis 'KEYS' "${@:1}"
}

# Atomically transfer a key from a Redis instance to another one.
redis::migrate() {
  redis::redis 'MIGRATE' "${@:1}"
}

# Move a key to another database
redis::move() {
  redis::redis 'MOVE' "${@:1}"
}

# Inspect the internals of Redis objects
redis::object() {
  redis::redis 'OBJECT' "${@:1}"
}

# Remove the expiration from a key
redis::persist() {
  redis::redis 'PERSIST' "${@:1}"
}

# Set a key's time to live in milliseconds
redis::pexpire() {
  redis::redis 'PEXPIRE' "${@:1}"
}

# Set the expiration for a key as a UNIX timestamp specified in milliseconds
redis::pexpireat() {
  redis::redis 'PEXPIREAT' "${@:1}"
}

# Get the time to live for a key in milliseconds
redis::pttl() {
  redis::redis 'PTTL' "${@:1}"
}

# Return a random key from the keyspace
redis::randomkey() {
  redis::redis 'RANDOMKEY'
}

# Rename a key
redis::rename() {
  redis::redis 'RENAME' "${@:1}"
}

# Rename a key, only if the new key does not exist
redis::renamenx() {
  redis::redis 'RENAMENX' "${@:1}"
}

# Create a key using the provided serialized value, previously obtained using DUMP.
redis::restore() {
  redis::redis 'RESTORE' "${@:1}"
}

# Incrementally iterate the keys space
redis::scan() {
  redis::redis 'SCAN' "${@:1}"
}

# Sort the elements in a list, set or sorted set
redis::sort() {
  redis::redis 'SORT' "${@:1}"
}

# Get the time to live for a key
redis::ttl() {
  redis::redis 'TTL' "${@:1}"
}

# Determine the type stored at key
redis::type() {
  redis::redis 'TYPE' "${@:1}"
}

#-------------------------------------------------------------------------------
# String commands
#-------------------------------------------------------------------------------

# Append a value to a key
redis::append() {
  redis::redis 'APPEND' "${@:1}"
}

# Count set bits in a string
redis::bitcount() {
  redis::redis 'BITCOUNT' "${@:1}"
}

# Perform bitwise operations between strings
redis::bitop() {
  redis::redis 'BITOP' "${@:1}"
}

# Find first bit set or clear in a string
redis::bitpos() {
  redis::redis 'BITPOS' "${@:1}"
}

# Decrement the integer value of a key by one
redis::decr() {
  redis::redis 'DECR' "${@:1}"
}

# Decrement the integer value of a key by the given number
redis::decrby() {
  redis::redis 'DECRBY' "${@:1}"
}

# Get the value of a key
redis::get() {
  redis::redis 'GET' "${@:1}"
}

# Returns the bit value at offset in the string value stored at key
redis::getbit() {
  redis::redis 'GETBIT' "${@:1}"
}

# Get a substring of the string stored at a key
redis::getrange() {
  redis::redis 'GETRANGE' "${@:1}"
}

# Set the string value of a key and return its old value
redis::getset() {
  redis::redis 'GETSET' "${@:1}"
}

# Increment the integer value of a key by one
redis::incr() {
  redis::redis 'INCR' "${@:1}"
}

# Increment the integer value of a key by the given amount
redis::incrby() {
  redis::redis 'INCRBY' "${@:1}"
}

# Increment the float value of a key by the given amount
redis::incrbyfloat() {
  redis::redis 'INCRBYFLOAT' "${@:1}"
}

# Get the values of all the given keys
redis::mget() {
  redis::redis 'MGET' "${@:1}"
}

# Set multiple keys to multiple values
redis::mset() {
  redis::redis 'MSET' "${@:1}"
}

# Set multiple keys to multiple values, only if none of the keys exist
redis::msetnx() {
  redis::redis 'MSETNX' "${@:1}"
}

# Set the value and expiration in milliseconds of a key
redis::psetex() {
  redis::redis 'PSETEX' "${@:1}"
}

# Set the string value of a key
redis::set() {
  redis::redis 'SET' "${@:1}"
}

# Sets or clears the bit at offset in the string value stored at key
redis::setbit() {
  redis::redis 'SETBIT' "${@:1}"
}

# Set the value and expiration of a key
redis::setex() {
  redis::redis 'SETEX' "${@:1}"
}

# Set the value of a key, only if the key does not exist
redis::setnx() {
  redis::redis 'SETNX' "${@:1}"
}

# Overwrite part of a string at key starting at the specified offset
redis::setrange() {
  redis::redis 'SETRANGE' "${@:1}"
}

# Get the length of the value stored in a key
redis::strlen() {
  redis::redis 'STRLEN' "${@:1}"
}

#-------------------------------------------------------------------------------
# Hash commands
#-------------------------------------------------------------------------------

# Delete one or more hash fields
redis::hdel() {
  redis::redis 'HDEL' "${@:1}"
}

# Determine if a hash field exists
redis::hexists() {
  redis::redis 'HEXISTS' "${@:1}"
}

# Get the value of a hash field
redis::hget() {
  redis::redis 'HGET' "${@:1}"
}

# Get all the fields and values in a hash
redis::hgetall() {
  redis::redis 'HGETALL' "${@:1}"
}

# Increment the integer value of a hash field by the given number
redis::hincrby() {
  redis::redis 'HINCRBY' "${@:1}"
}

# Increment the float value of a hash field by the given amount
redis::hincrbyfloat() {
  redis::redis 'HINCRBYFLOAT' "${@:1}"
}

# Get all the fields in a hash
redis::hkeys() {
  redis::redis 'HKEYS' "${@:1}"
}

# Get the number of fields in a hash
redis::hlen() {
  redis::redis 'HLEN' "${@:1}"
}

# Get the values of all the given hash fields
redis::hmget() {
  redis::redis 'HMGET' "${@:1}"
}

# Set multiple hash fields to multiple values
redis::hmset() {
  redis::redis 'HMSET' "${@:1}"
}

# Incrementally iterate hash fields and associated values
redis::hscan() {
  redis::redis 'HSCAN' "${@:1}"
}

# Set the string value of a hash field
redis::hset() {
  redis::redis 'HSET' "${@:1}"
}

# Set the value of a hash field, only if the field does not exist
redis::hsetnx() {
  redis::redis 'HSETNX' "${@:1}"
}

# Get all the values in a hash
redis::hvals() {
  redis::redis 'HVALS' "${@:1}"
}

#-------------------------------------------------------------------------------
# List commands
#-------------------------------------------------------------------------------

# Remove and get the first element in a list, or block until one is available
redis::blpop() {
  redis::redis 'BLPOP' "${@:1}"
}

# Remove and get the last element in a list, or block until one is available
redis::brpop() {
  redis::redis 'BRPOP' "${@:1}"
}

# Pop a value from a list, push it to another list and return it; or block until one is available
redis::brpoplpush() {
  redis::redis 'BRPOPLPUSH' "${@:1}"
}

# Get an element from a list by its index
redis::lindex() {
  redis::redis 'LINDEX' "${@:1}"
}

# Insert an element before or after another element in a list
redis::linsert() {
  redis::redis 'LINSERT' "${@:1}"
}

# Get the length of a list
redis::llen() {
  redis::redis 'LLEN' "${@:1}"
}

# Remove and get the first element in a list
redis::lpop() {
  redis::redis 'LPOP' "${@:1}"
}

# Prepend one or multiple values to a list
redis::lpush() {
  redis::redis 'LPUSH' "${@:1}"
}

# Prepend a value to a list, only if the list exists
redis::lpushx() {
  redis::redis 'LPUSHX' "${@:1}"
}

# Get a range of elements from a list
redis::lrange() {
  redis::redis 'LRANGE' "${@:1}"
}

# Remove elements from a list
redis::lrem() {
  redis::redis 'LREM' "${@:1}"
}

# Set the value of an element in a list by its index
redis::lset() {
  redis::redis 'LSET' "${@:1}"
}

# Trim a list to the specified range
redis::ltrim() {
  redis::redis 'LTRIM' "${@:1}"
}

# Remove and get the last element in a list
redis::rpop() {
  redis::redis 'RPOP' "${@:1}"
}

# Remove the last element in a list, append it to another list and return it
redis::rpoplpush() {
  redis::redis 'RPOPLPUSH' "${@:1}"
}

# Append one or multiple values to a list
redis::rpush() {
  redis::redis 'RPUSH' "${@:1}"
}

# Append a value to a list, only if the list exists
redis::rpushx() {
  redis::redis 'RPUSHX' "${@:1}"
}

#-------------------------------------------------------------------------------
# Set commands
#-------------------------------------------------------------------------------

# Add one or more members to a set
redis::sadd() {
  redis::redis 'SADD' "${@:1}"
}

# Get the number of members in a set
redis::scard() {
  redis::redis 'SCARD' "${@:1}"
}

# Subtract multiple sets
redis::sdiff() {
  redis::redis 'SDIFF' "${@:1}"
}

# Subtract multiple sets and store the resulting set in a key
redis::sdiffstore() {
  redis::redis 'SDIFFSTORE' "${@:1}"
}

# Intersect multiple sets
redis::sinter() {
  redis::redis 'SINTER' "${@:1}"
}

# Intersect multiple sets and store the resulting set in a key
redis::sinterstore() {
  redis::redis 'SINTERSTORE' "${@:1}"
}

# Determine if a given value is a member of a set
redis::sismember() {
  redis::redis 'SISMEMBER' "${@:1}"
}

# Get all the members in a set
redis::smembers() {
  redis::redis 'SMEMBERS' "${@:1}"
}

# Move a member from one set to another
redis::smove() {
  redis::redis 'SMOVE' "${@:1}"
}

# Remove and return a random member from a set
redis::spop() {
  redis::redis 'SPOP' "${@:1}"
}

# Get one or multiple random members from a set
redis::srandmember() {
  redis::redis 'SRANDMEMBER' "${@:1}"
}

# Remove one or more members from a set
redis::srem() {
  redis::redis 'SREM' "${@:1}"
}

# Incrementally iterate Set elements
redis::sscan() {
  redis::redis 'SSCAN' "${@:1}"
}

# Add multiple sets
redis::sunion() {
  redis::redis 'SUNION' "${@:1}"
}

# Add multiple sets and store the resulting set in a key
redis::sunionstore() {
  redis::redis 'SUNIONSTORE' "${@:1}"
}

#-------------------------------------------------------------------------------
# Sorted Set commands
#-------------------------------------------------------------------------------

# Add one or more members to a sorted set, or update its score if it already exists
redis::zadd() {
  redis::redis 'ZADD' "${@:1}"
}

# Get the number of members in a sorted set
redis::zcard() {
  redis::redis 'ZCARD' "${@:1}"
}

# Count the members in a sorted set with scores within the given values
redis::zcount() {
  redis::redis 'ZCOUNT' "${@:1}"
}

# Increment the score of a member in a sorted set
redis::zincrby() {
  redis::redis 'ZINCRBY' "${@:1}"
}

# Intersect multiple sorted sets and store the resulting sorted set in a new key
redis::zinterstore() {
  redis::redis 'ZINTERSTORE' "${@:1}"
}

# Count the number of members in a sorted set between a given lexicographical range
redis::zlexcount() {
  redis::redis 'ZLEXCOUNT' "${@:1}"
}

# Return a range of members in a sorted set, by index
redis::zrange() {
  redis::redis 'ZRANGE' "${@:1}"
}

# Return a range of members in a sorted set, by lexicographical range
redis::zrangebylex() {
  redis::redis 'ZRANGEBYLEX' "${@:1}"
}

# Return a range of members in a sorted set, by score
redis::zrangebyscore() {
  redis::redis 'ZRANGEBYSCORE' "${@:1}"
}

# Determine the index of a member in a sorted set
redis::zrank() {
  redis::redis 'ZRANK' "${@:1}"
}

# Remove one or more members from a sorted set
redis::zrem() {
  redis::redis 'ZREM' "${@:1}"
}

# Remove all members in a sorted set between the given lexicographical range
redis::zremrangebylex() {
  redis::redis 'ZREMRANGEBYLEX' "${@:1}"
}

# Remove all members in a sorted set within the given indexes
redis::zremrangebyrank() {
  redis::redis 'ZREMRANGEBYRANK' "${@:1}"
}

# Remove all members in a sorted set within the given scores
redis::zremrangebyscore() {
  redis::redis 'ZREMRANGEBYSCORE' "${@:1}"
}

# Return a range of members in a sorted set, by index, with scores ordered from high to low
redis::zrevrange() {
  redis::redis 'ZREVRANGE' "${@:1}"
}

# Return a range of members in a sorted set, by score, with scores ordered from high to low
redis::zrevrangebyscore() {
  redis::redis 'ZREVRANGEBYSCORE' "${@:1}"
}

# Determine the index of a member in a sorted set, with scores ordered from high to low
redis::zrevrank() {
  redis::redis 'ZREVRANK' "${@:1}"
}

# Incrementally iterate sorted sets elements and associated scores
redis::zscan() {
  redis::redis 'ZSCAN' "${@:1}"
}

# Get the score associated with the given member in a sorted set
redis::zscore() {
  redis::redis 'ZSCORE' "${@:1}"
}

# Add multiple sorted sets and store the resulting sorted set in a new key
redis::zunionstore() {
  redis::redis 'ZUNIONSTORE' "${@:1}"
}

#-------------------------------------------------------------------------------
# HyperLogLog commands
#-------------------------------------------------------------------------------

# Adds the specified elements to the specified HyperLogLog.
redis::pfadd() {
  redis::redis 'PFADD' "${@:1}"
}

# Return the approximated cardinality of the set(s) observed by the HyperLogLog at key(s).
redis::pfcount() {
  redis::redis 'PFCOUNT' "${@:1}"
}

# Merge N different HyperLogLogs into a single one.
redis::pfmerge() {
  redis::redis 'PFMERGE' "${@:1}"
}

#-------------------------------------------------------------------------------
# Pub/Sub commands
#-------------------------------------------------------------------------------

# Listen for messages published to channels matching the given patterns
redis::psubscribe() {
  redis::redis 'PSUBSCRIBE' "${@:1}"
}

# Post a message to a channel
redis::publish() {
  redis::redis 'PUBLISH' "${@:1}"
}

# Inspect the state of the Pub/Sub subsystem
redis::pubsub() {
  redis::redis 'PUBSUB' "${@:1}"
}

# Stop listening for messages posted to channels matching the given patterns
redis::punsubscribe() {
  redis::redis 'PUNSUBSCRIBE' "${@:1}"
}

# Listen for messages published to the given channels
redis::subscribe() {
  redis::redis 'SUBSCRIBE' "${@:1}"
}

# Stop listening for messages posted to the given channels
redis::unsubscribe() {
  redis::redis 'UNSUBSCRIBE' "${@:1}"
}

#-------------------------------------------------------------------------------
# Transaction commands
#-------------------------------------------------------------------------------

# Discard all commands issued after MULTI
redis::discard() {
  redis::redis 'DISCARD'
}

# Execute all commands issued after MULTI
redis::exec() {
  redis::redis 'EXEC'
}

# Mark the start of a transaction block
redis::multi() {
  redis::redis 'MULTI'
}

# Forget about all watched keys
redis::unwatch() {
  redis::redis 'UNWATCH'
}

# Watch the given keys to determine execution of the MULTI/EXEC block
redis::watch() {
  redis::redis 'WATCH' "${@:1}"
}

#-------------------------------------------------------------------------------
# Scripting commands
#-------------------------------------------------------------------------------

# Execute a Lua script server side
redis::eval() {
  redis::redis 'EVAL' "${@:1}"
}

# Execute a Lua script server side
redis::evalsha() {
  redis::redis 'EVALSHA' "${@:1}"
}

# Check existence of scripts in the script cache.
redis::script_exists() {
  redis::redis 'SCRIPT EXISTS' "${@:1}"
}

# Remove all the scripts from the script cache.
redis::script_flush() {
  redis::redis 'SCRIPT FLUSH'
}

# Kill the script currently in execution.
redis::script_kill() {
  redis::redis 'SCRIPT KILL'
}

# Load the specified Lua script into the script cache.
redis::script_load() {
  redis::redis 'SCRIPT LOAD' "${@:1}"
}

#-------------------------------------------------------------------------------
# Connection commands
#-------------------------------------------------------------------------------

# Authenticate to the server
redis::auth() {
  redis::redis 'AUTH' "${@:1}"
}

# Echo the given string
redis::echo() {
  redis::redis 'ECHO' "${@:1}"
}

# Ping the server
redis::ping() {
  redis::redis 'PING'
}

# Close the connection
redis::quit() {
  redis::redis 'QUIT'
}

# Change the selected database for the current connection
redis::select() {
  redis::redis 'SELECT' "${@:1}"
}

#-------------------------------------------------------------------------------
# Server commands
#-------------------------------------------------------------------------------

# Asynchronously rewrite the append-only file
redis::bgrewriteaof() {
  redis::redis 'BGREWRITEAOF'
}

# Asynchronously save the dataset to disk
redis::bgsave() {
  redis::redis 'BGSAVE'
}

# Get the current connection name
redis::client_getname() {
  redis::redis 'CLIENT GETNAME'
}

# Kill the connection of a client
redis::client_kill() {
  redis::redis 'CLIENT KILL' "${@:1}"
}

# Get the list of client connections
redis::client_list() {
  redis::redis 'CLIENT LIST'
}

# Stop processing commands from clients for some time
redis::client_pause() {
  redis::redis 'CLIENT PAUSE' "${@:1}"
}

# Set the current connection name
redis::client_setname() {
  redis::redis 'CLIENT SETNAME' "${@:1}"
}

# Get the value of a configuration parameter
redis::config_get() {
  redis::redis 'CONFIG GET' "${@:1}"
}

# Reset the stats returned by INFO
redis::config_resetstat() {
  redis::redis 'CONFIG RESETSTAT'
}

# Rewrite the configuration file with the in memory configuration
redis::config_rewrite() {
  redis::redis 'CONFIG REWRITE'
}

# Set a configuration parameter to the given value
redis::config_set() {
  redis::redis 'CONFIG SET' "${@:1}"
}

# Return the number of keys in the selected database
redis::dbsize() {
  redis::redis 'DBSIZE'
}

# Get debugging information about a key
redis::debug_object() {
  redis::redis 'DEBUG OBJECT' "${@:1}"
}

# Make the server crash
redis::debug_segfault() {
  redis::redis 'DEBUG SEGFAULT'
}

# Remove all keys from all databases
redis::flushall() {
  redis::redis 'FLUSHALL'
}

# Remove all keys from the current database
redis::flushdb() {
  redis::redis 'FLUSHDB'
}

# Get information and statistics about the server
redis::info() {
  redis::redis 'INFO' "${@:1}"
}

# Get the UNIX time stamp of the last successful save to disk
redis::lastsave() {
  redis::redis 'LASTSAVE'
}

# Listen for all requests received by the server in real time
redis::monitor() {
  redis::redis 'MONITOR'
}

# Return the role of the instance in the context of replication
redis::role() {
  redis::redis 'ROLE'
}

# Synchronously save the dataset to disk
redis::save() {
  redis::redis 'SAVE'
}

# Synchronously save the dataset to disk and then shut down the server
redis::shutdown() {
  redis::redis 'SHUTDOWN' "${@:1}"
}

# Make the server a slave of another instance, or promote it as master
redis::slaveof() {
  redis::redis 'SLAVEOF' "${@:1}"
}

# Manages the Redis slow queries log
redis::slowlog() {
  redis::redis 'SLOWLOG' "${@:1}"
}

# Internal command used for replication
redis::sync() {
  redis::redis 'SYNC'
}

# Return the current server time
redis::time() {
  redis::redis 'TIME'
}
