# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for string commands

load test_helper

# Append a value to a key
@test "APPEND key value" {
  run redis::append mykey "Hello"
  assert_equal "${output}" "5"
  run redis::append mykey " World"
  assert_equal "${output}" "11"
  run redis::get mykey
  assert_equal "${output}" "Hello World"
}

# Count set bits in a string
@test "BITCOUNT key [start] [end]" {
  run redis::set mykey "foobar"
  assert_ok "${output}"
  run redis::bitcount mykey
  assert_equal "${output}" "26"
  run redis::bitcount mykey 0 0
  assert_equal "${output}" "4"
  run redis::bitcount mykey 1 1
  assert_equal "${output}" "6"
}

# Perform bitwise operations between strings
@test "BITOP operation destkey key [key ...]" {
  run redis::set key1 "foobar"
  assert_ok "${output}"
  run redis::set key2 "abcdef"
  assert_ok "${output}"
  run redis::bitop AND dest key1 key2
  assert_equal "${output}" "6"
  run redis::get dest
  assert_equal "${output}" "\`bc\`ab"
}

# Find first bit set or clear in a string
@test "BITPOS key bit [start] [end]" {
  # TODO: Fix hex handling. Bash always converts to empty strings.
  run redis::set mykey $'\xff\xf0\x00'
  assert_ok "${output}"
  run redis::bitpos mykey 0
  assert_equal "${output}" 12
  run redis::set mykey $'\x00\xff\xf0'
  assert_ok "${output}"
  run redis::bitpos mykey 1 0
  assert_equal "${output}" 8
  run redis::bitpos mykey 1 1
  assert_equal "${output}" 8
  run redis::set mykey $'\x00\x00\x00'
  assert_ok "${output}"
  run redis::bitpos mykey 1
  assert_equal "${output}" -1
}

# Decrement the integer value of a key by one
@test "DECR key" {
  run redis::set mykey 10
  assert_ok "${output}"
  run redis::decr mykey
  assert_equal "${output}" 9
  run redis::set mykey "234293482390480948029348230948"
  assert_ok "${output}"
  run redis::decr mykey
  assert_error "${output}"
  assert_equal "${output}" "ERR value is not an integer or out of range"
}

# Decrement the integer value of a key by the given number
@test "DECRBY key decrement" {
  run redis::set mykey 10
  assert_ok "${output}"
  run redis::decrby mykey 5
  assert_equal "${output}" 5
}

# Get the value of a key
@test "GET key" {
  run redis::get nonexisting
  assert_equal "${output}" "(nil)"
  run redis::set mykey "Hello"
  assert_ok "${output}"
  run redis::get mykey
  assert_equal "${output}" "Hello"
}

# Returns the bit value at offset in the string value stored at key
@test "GETBIT key offset" {
  run redis::setbit mykey 7 1
  assert_equal "${output}" 0
  run redis::getbit mykey 0
  assert_equal "${output}" 0
  run redis::getbit mykey 7
  assert_equal "${output}" 1
  run redis::getbit mykey 100
  assert_equal "${output}" 0
}

# Get a substring of the string stored at a key
@test "GETRANGE key start end" {
  run redis::set mykey "This is a string"
  assert_ok "${output}"
  run redis::getrange mykey 0 3
  assert_equal "${output}" "This"
  run redis::getrange mykey -3 -1
  assert_equal "${output}" "ing"
  run redis::getrange mykey 0 -1
  assert_equal "${output}" "This is a string"
  run redis::getrange mykey 10 100
  assert_equal "${output}" "string"
}

# Set the string value of a key and return its old value
@test "GETSET key value" {
  run redis::incr mycounter
  assert_equal "${output}" 1
  run redis::getset mycounter "0"
  assert_equal "${output}" 1
  run redis::get mycounter
  assert_equal "${output}" "0"
}

# Increment the integer value of a key by one
@test "INCR key" {
  run redis::set mykey 10
  assert_ok "${output}"
  run redis::incr mykey
  assert_equal "${output}" 11
  run redis::get mykey
  assert_equal "${output}" 11
}

# Increment the integer value"of a key by the given amount
@test "INCRBY key increment" {
  run redis::set mykey 10
  assert_ok "${output}"
  run redis::incrby mykey 5
  assert_equal "${output}" 15
}

# Increment the float value of a key by the given amount
@test "INCRBYFLOAT key increment" {
  run redis::set mykey 10.50
  assert_ok "${output}"
  run redis::incrbyfloat mykey 0.1
  assert_equal "${output}" 10.6
  run redis::set mykey 5.0e3
  assert_equal "${output}" OK
  run redis::incrbyfloat mykey 2.0e2
  assert_equal "${output}" 5200
}

# Get the values of all the given keys
@test "MGET key [key ...]" {
  # TODO: Fix Array handling (#2)
  fail 'test not defined yet'
}

# Set multiple keys to multiple values
@test "MSET key value [key value ...]" {
  run redis::mset key1 "Hello" key2 "World"
  assert_ok "${output}"
  run redis::get key1
  assert_equal "${output}" "Hello"
  run redis::get key2
  assert_equal "${output}" "World"
}

# Set multiple keys to multiple values, only if none of the keys exist
@test "MSETNX key value [key value ...]" {
  # TODO: Fix Array handling (#2)
  fail 'test not defined yet'
}

# Set the value and expiration in milliseconds of a key
@test "PSETEX key milliseconds value" {
  run redis::psetex mykey 1000 "Hello"
  assert_ok "${output}"
  # TODO: Figure out how to test this in a repeatable way (running PTTL will
  # return different results each test).
#  run redis::pttl mykey
#  assert_equal "${output}" 999
  run redis::get mykey
  assert_equal "${output}" "Hello"
}

# Set the string value of a key
@test "SET key value [EX seconds] [PX milliseconds] [NX|XX]" {
  run redis::set mykey Hello
  assert_equal "${output}" OK
  run redis::get mykey
  assert_equal "${output}" Hello
}

# Sets or clears the bit at offset in the string value stored at key
@test "SETBIT key offset value" {
  run redis::setbit mykey 7 1
  assert_equal "${output}" 0
  run redis::setbit mykey 7 0
  assert_equal "${output}" 1
  # TODO: Fix hex handling. Bash always converts to empty strings.
  run redis::get mykey
  assert_equal "${output}" $'\u0000'
}

# Set the value and expiration of a key
@test "SETEX key seconds value" {
  run redis::setex mykey 10 "Hello"
  assert_ok "${output}"
  run redis::ttl mykey
  assert_equal "${output}" 10
  run redis::get mykey
  assert_equal "${output}" "Hello"
}

# Set the value of a key, only if the key does not exist
@test "SETNX key value" {
  run redis::setnx mykey "Hello"
  assert_equal "${output}" 1
  run redis::setnx mykey "World"
  assert_equal "${output}" 0
  run redis::get mykey
  assert_equal "${output}" "Hello"
}

# Overwrite part of a string at key starting at the specified offset
@test "SETRANGE key offset value" {
  run redis::set key1 "Hello World"
  assert_ok "${output}"
  run redis::setrange key1 6 "Redis"
  assert_equal "${output}" 11
  run redis::get key1
  assert_equal "${output}" "Hello Redis"
}

# Get the length of the value stored in a key
@test "STRLEN key" {
  run redis::set mykey "Hello world"
  assert_ok "${output}"
  run redis::strlen mykey
  assert_equal "${output}" 11
  run redis::strlen "nonexisting"
  assert_equal "${output}" 0
}
