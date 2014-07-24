# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for pubsub commands

load test_helper

@test 'PSUBSCRIBE' {
  run redis::psubscribe
  fail 'test not defined yet'
}

@test 'PUBLISH' {
  run redis::publish
  fail 'test not defined yet'
}

@test 'PUBSUB' {
  run redis::pubsub
  fail 'test not defined yet'
}

@test 'PUNSUBSCRIBE' {
  run redis::punsubscribe
  fail 'test not defined yet'
}

@test 'SUBSCRIBE' {
  run redis::subscribe
  fail 'test not defined yet'
}

@test 'UNSUBSCRIBE' {
  run redis::unsubscribe
  fail 'test not defined yet'
}
