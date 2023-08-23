# Hiredis.jl
A Julia wrapper for [hiredis](https://github.com/redis/hiredis), a minimalistic C client library for the [Redis](https://redis.io) database.

Importantly, in contrast to [Redis.jl](https://github.com/JuliaDatabases/Redis.jl), Hiredis.jl supports TLS connections.

# Usage
The following example illustrates how Hiredis.jl can be used.

```julia
using Hiredis

client = RedisClient(
    host = "192.168.0.1",
    port = 6380,
    password = "some_secure_password",
    ssl = true,
    cacert_filename = "/usr/lib/ssl/certs/ca-certificates.crt"
)

set(client, "foo", "bar")
get(client, "foo") # returns "bar"

disconnect!(client)
```