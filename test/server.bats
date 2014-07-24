# vi: set ft=sh :
#!/usr/bin/env bats

# redis.sh tests for server commands

load test_helper

@test 'BGREWRITEAOF' {
  run redis::bgrewriteaof
  fail 'test not defined yet'
}

@test 'BGSAVE' {
  run redis::bgsave
  fail 'test not defined yet'
}

@test 'CLIENT_GETNAME' {
  run redis::client_getname
  fail 'test not defined yet'
}

@test 'CLIENT_KILL' {
  run redis::client_kill
  fail 'test not defined yet'
}

@test 'CLIENT_LIST' {
  run redis::client_list
  fail 'test not defined yet'
}

@test 'CLIENT_PAUSE' {
  run redis::client_pause
  fail 'test not defined yet'
}

@test 'CLIENT_SETNAME' {
  run redis::client_setname
  fail 'test not defined yet'
}

@test 'CONFIG_GET' {
  run redis::config_get
  fail 'test not defined yet'
}

@test 'CONFIG_RESETSTAT' {
  run redis::config_resetstat
  fail 'test not defined yet'
}

@test 'CONFIG_REWRITE' {
  run redis::config_rewrite
  fail 'test not defined yet'
}

@test 'CONFIG_SET' {
  run redis::config_set
  fail 'test not defined yet'
}

@test 'DBSIZE' {
  run redis::dbsize
  fail 'test not defined yet'
}

@test 'DEBUG_OBJECT' {
  run redis::debug_object
  fail 'test not defined yet'
}

@test 'DEBUG_SEGFAULT' {
  run redis::debug_segfault
  fail 'test not defined yet'
}

@test 'FLUSHALL' {
  run redis::flushall
  fail 'test not defined yet'
}

@test 'FLUSHDB' {
  run redis::flushdb
  fail 'test not defined yet'
}

@test 'INFO' {
  run redis::info
  fail 'test not defined yet'
}

@test 'LASTSAVE' {
  run redis::lastsave
  fail 'test not defined yet'
}

@test 'MONITOR' {
  run redis::monitor
  fail 'test not defined yet'
}

@test 'ROLE' {
  run redis::role
  fail 'test not defined yet'
}

@test 'SAVE' {
  run redis::save
  fail 'test not defined yet'
}

@test 'SHUTDOWN' {
  run redis::shutdown
  fail 'test not defined yet'
}

@test 'SLAVEOF' {
  run redis::slaveof
  fail 'test not defined yet'
}

@test 'SLOWLOG' {
  run redis::slowlog
  fail 'test not defined yet'
}

@test 'SYNC' {
  run redis::sync
  fail 'test not defined yet'
}

@test 'TIME' {
  run redis::time
  fail 'test not defined yet'
}
