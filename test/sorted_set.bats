# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for sorted_set commands

load test_helper

@test 'ZADD' {
  run redis::zadd
  fail 'test not defined yet'
}

@test 'ZCARD' {
  run redis::zcard
  fail 'test not defined yet'
}

@test 'ZCOUNT' {
  run redis::zcount
  fail 'test not defined yet'
}

@test 'ZINCRBY' {
  run redis::zincrby
  fail 'test not defined yet'
}

@test 'ZINTERSTORE' {
  run redis::zinterstore
  fail 'test not defined yet'
}

@test 'ZLEXCOUNT' {
  run redis::zlexcount
  fail 'test not defined yet'
}

@test 'ZRANGE' {
  run redis::zrange
  fail 'test not defined yet'
}

@test 'ZRANGEBYLEX' {
  run redis::zrangebylex
  fail 'test not defined yet'
}

@test 'ZRANGEBYSCORE' {
  run redis::zrangebyscore
  fail 'test not defined yet'
}

@test 'ZRANK' {
  run redis::zrank
  fail 'test not defined yet'
}

@test 'ZREM' {
  run redis::zrem
  fail 'test not defined yet'
}

@test 'ZREMRANGEBYLEX' {
  run redis::zremrangebylex
  fail 'test not defined yet'
}

@test 'ZREMRANGEBYRANK' {
  run redis::zremrangebyrank
  fail 'test not defined yet'
}

@test 'ZREMRANGEBYSCORE' {
  run redis::zremrangebyscore
  fail 'test not defined yet'
}

@test 'ZREVRANGE' {
  run redis::zrevrange
  fail 'test not defined yet'
}

@test 'ZREVRANGEBYSCORE' {
  run redis::zrevrangebyscore
  fail 'test not defined yet'
}

@test 'ZREVRANK' {
  run redis::zrevrank
  fail 'test not defined yet'
}

@test 'ZSCAN' {
  run redis::zscan
  fail 'test not defined yet'
}

@test 'ZSCORE' {
  run redis::zscore
  fail 'test not defined yet'
}

@test 'ZUNIONSTORE' {
  run redis::zunionstore
  fail 'test not defined yet'
}
