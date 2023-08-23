ping(client::RedisClient) = execute_command(client, "PING", String)

Base.get(client::RedisClient, key::AbstractString) =
    execute_command(client, "GET $key", String)

set(client::RedisClient, key::AbstractString, value::AbstractString) =
    execute_command(client, "SET $key $value", Nothing)

del(client::RedisClient, key::AbstractString) = execute_command(client, "DEL $key", Int)

exists(client::RedisClient, key::AbstractString) =
    execute_command(client, "EXISTS $key", Int) == 1

expire(client::RedisClient, key::AbstractString, seconds::Number) =
    execute_command(client, "EXPIRE $key $seconds", Nothing)

flushall(client::RedisClient) = execute_command(client, "FLUSHALL", Nothing)
