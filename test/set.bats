# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for set commands

load test_helper

@test 'SADD' {
  run redis::sadd
  fail 'test not defined yet'
}

@test 'SCARD' {
  run redis::scard
  fail 'test not defined yet'
}

@test 'SDIFF' {
  run redis::sdiff
  fail 'test not defined yet'
}

@test 'SDIFFSTORE' {
  run redis::sdiffstore
  fail 'test not defined yet'
}

@test 'SINTER' {
  run redis::sinter
  fail 'test not defined yet'
}

@test 'SINTERSTORE' {
  run redis::sinterstore
  fail 'test not defined yet'
}

@test 'SISMEMBER' {
  run redis::sismember
  fail 'test not defined yet'
}

@test 'SMEMBERS' {
  run redis::smembers
  fail 'test not defined yet'
}

@test 'SMOVE' {
  run redis::smove
  fail 'test not defined yet'
}

@test 'SPOP' {
  run redis::spop
  fail 'test not defined yet'
}

@test 'SRANDMEMBER' {
  run redis::srandmember
  fail 'test not defined yet'
}

@test 'SREM' {
  run redis::srem
  fail 'test not defined yet'
}

@test 'SSCAN' {
  run redis::sscan
  fail 'test not defined yet'
}

@test 'SUNION' {
  run redis::sunion
  fail 'test not defined yet'
}

@test 'SUNIONSTORE' {
  run redis::sunionstore
  fail 'test not defined yet'
}
