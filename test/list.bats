# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for list commands

load test_helper

@test 'BLPOP' {
  run redis::blpop
  fail 'test not defined yet'
}

@test 'BRPOP' {
  run redis::brpop
  fail 'test not defined yet'
}

@test 'BRPOPLPUSH' {
  run redis::brpoplpush
  fail 'test not defined yet'
}

@test 'LINDEX' {
  run redis::lindex
  fail 'test not defined yet'
}

@test 'LINSERT' {
  run redis::linsert
  fail 'test not defined yet'
}

@test 'LLEN' {
  run redis::llen
  fail 'test not defined yet'
}

@test 'LPOP' {
  run redis::lpop
  fail 'test not defined yet'
}

@test 'LPUSH' {
  run redis::lpush
  fail 'test not defined yet'
}

@test 'LPUSHX' {
  run redis::lpushx
  fail 'test not defined yet'
}

@test 'LRANGE' {
  run redis::lrange
  fail 'test not defined yet'
}

@test 'LREM' {
  run redis::lrem
  fail 'test not defined yet'
}

@test 'LSET' {
  run redis::lset
  fail 'test not defined yet'
}

@test 'LTRIM' {
  run redis::ltrim
  fail 'test not defined yet'
}

@test 'RPOP' {
  run redis::rpop
  fail 'test not defined yet'
}

@test 'RPOPLPUSH' {
  run redis::rpoplpush
  fail 'test not defined yet'
}

@test 'RPUSH' {
  run redis::rpush
  fail 'test not defined yet'
}

@test 'RPUSHX' {
  run redis::rpushx
  fail 'test not defined yet'
}
