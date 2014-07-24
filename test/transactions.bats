# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for transactions commands

load test_helper

@test 'DISCARD' {
  run redis::discard
  fail 'test not defined yet'
}

@test 'EXEC' {
  run redis::exec
  fail 'test not defined yet'
}

@test 'MULTI' {
  run redis::multi
  fail 'test not defined yet'
}

@test 'UNWATCH' {
  run redis::unwatch
  fail 'test not defined yet'
}

@test 'WATCH' {
  run redis::watch
  fail 'test not defined yet'
}
