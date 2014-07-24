# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for hash commands

load test_helper

@test 'HDEL' {
  run redis::hdel
  fail 'test not defined yet'
}

@test 'HEXISTS' {
  run redis::hexists
  fail 'test not defined yet'
}

@test 'HGET' {
  run redis::hget
  fail 'test not defined yet'
}

@test 'HGETALL' {
  run redis::hgetall
  fail 'test not defined yet'
}

@test 'HINCRBY' {
  run redis::hincrby
  fail 'test not defined yet'
}

@test 'HINCRBYFLOAT' {
  run redis::hincrbyfloat
  fail 'test not defined yet'
}

@test 'HKEYS' {
  run redis::hkeys
  fail 'test not defined yet'
}

@test 'HLEN' {
  run redis::hlen
  fail 'test not defined yet'
}

@test 'HMGET' {
  run redis::hmget
  fail 'test not defined yet'
}

@test 'HMSET' {
  run redis::hmset
  fail 'test not defined yet'
}

@test 'HSCAN' {
  run redis::hscan
  fail 'test not defined yet'
}

@test 'HSET' {
  run redis::hset
  fail 'test not defined yet'
}

@test 'HSETNX' {
  run redis::hsetnx
  fail 'test not defined yet'
}

@test 'HVALS' {
  run redis::hvals
  fail 'test not defined yet'
}
