# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for connection commands

load test_helper

@test 'AUTH' {
  run redis::auth
  fail 'test not defined yet'
}

@test 'ECHO' {
  run redis::echo
  fail 'test not defined yet'
}

@test 'PING' {
  run redis::ping
  fail 'test not defined yet'
}

@test 'QUIT' {
  run redis::quit
  fail 'test not defined yet'
}

@test 'SELECT' {
  run redis::select
  fail 'test not defined yet'
}
