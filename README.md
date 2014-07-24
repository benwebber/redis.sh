# redis.sh

Pure Bash client library for Redis.

## Usage

1. Download [`redis.sh`](https://github.com/benwebber/redis.sh/raw/master/redis.sh).
2. Source the file in your Bash script.

    ```sh
    . ./redis.sh
    ```

3. Connect to a Redis instance and run your commands.

    ```sh
    redis::info
    ```

By default, `redis.sh` will attempt to connect on `localhost:6379`. You can override that by setting `REDIS_HOSTNAME` and `REDIS_PORT`.

```sh
REDIS_HOSTNAME='redis.example.org'
REDIS_PORT=6380
redis::info
```

## How it works

Bash exposes a file-like interface for socket connections through the [`/dev/tcp` pseudo-device](http://www.tldp.org/LDP/abs/html/devref1.html). `redis.sh` takes advantage of this feature to talk to Redis using the [Redis wire protocol](http://redis.io/topics/protocol/).

This is a Bashism; `redis.sh` is not compatible with stricter shells such as `ash`. A POSIX-compliant implementation would rely on external utilities such as `socat` or `nc` to establish socket connections.

## Why use redis.sh?

Here are some possible use cases:

* ultra-portable monitoring scripts
* fetching or updating information in Redis during deploys
* session storage for [Bash on Balls](https://github.com/jneen/balls/)

## Contributing

`redis.sh` is still missing a lot of critical functionality (see [open issues](https://github.com/benwebber/redis.sh/issues/)). Pull requests are appreciated.

### Testing

We are using [Bats](https://github.com/sstephenson/bats/) as a testing framework. Refer to the Bats documentation for installation instructions.

Once you have Bats installed, run tests using:

```
$ make test
```

or simply:

```
$ bats test
```
