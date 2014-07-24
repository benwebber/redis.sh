# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for generic commands

load test_helper

@test 'DEL' {
  run redis::del
  fail 'test not defined yet'
}

@test 'DUMP' {
  run redis::dump
  fail 'test not defined yet'
}

@test 'EXISTS' {
  run redis::exists
  fail 'test not defined yet'
}

@test 'EXPIRE' {
  run redis::expire
  fail 'test not defined yet'
}

@test 'EXPIREAT' {
  run redis::expireat
  fail 'test not defined yet'
}

@test 'KEYS' {
  run redis::keys
  fail 'test not defined yet'
}

@test 'MIGRATE' {
  run redis::migrate
  fail 'test not defined yet'
}

@test 'MOVE' {
  run redis::move
  fail 'test not defined yet'
}

@test 'OBJECT' {
  run redis::object
  fail 'test not defined yet'
}

@test 'PERSIST' {
  run redis::persist
  fail 'test not defined yet'
}

@test 'PEXPIRE' {
  run redis::pexpire
  fail 'test not defined yet'
}

@test 'PEXPIREAT' {
  run redis::pexpireat
  fail 'test not defined yet'
}

@test 'PTTL' {
  run redis::pttl
  fail 'test not defined yet'
}

@test 'RANDOMKEY' {
  run redis::randomkey
  fail 'test not defined yet'
}

@test 'RENAME' {
  run redis::rename
  fail 'test not defined yet'
}

@test 'RENAMENX' {
  run redis::renamenx
  fail 'test not defined yet'
}

@test 'RESTORE' {
  run redis::restore
  fail 'test not defined yet'
}

@test 'SCAN' {
  run redis::scan
  fail 'test not defined yet'
}

@test 'SORT' {
  run redis::sort
  fail 'test not defined yet'
}

@test 'TTL' {
  run redis::ttl
  fail 'test not defined yet'
}

@test 'TYPE' {
  run redis::type
  fail 'test not defined yet'
}
