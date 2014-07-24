# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for scripting commands

load test_helper

@test 'EVAL' {
  run redis::eval
  fail 'test not defined yet'
}

@test 'EVALSHA' {
  run redis::evalsha
  fail 'test not defined yet'
}

@test 'SCRIPT EXISTS' {
  run redis::script_exists
  fail 'test not defined yet'
}

@test 'SCRIPT FLUSH' {
  run redis::script_flush
  fail 'test not defined yet'
}

@test 'SCRIPT KILL' {
  run redis::script_kill
  fail 'test not defined yet'
}

@test 'SCRIPT LOAD' {
  run redis::script_load
  fail 'test not defined yet'
}
