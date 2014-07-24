# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for hyperloglog commands

load test_helper

@test 'PFADD' {
  run redis::pfadd
  fail 'test not defined yet'
}

@test 'PFCOUNT' {
  run redis::pfcount
  fail 'test not defined yet'
}

@test 'PFMERGE' {
  run redis::pfmerge
  fail 'test not defined yet'
}
