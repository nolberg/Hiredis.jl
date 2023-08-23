struct RedisException <: Exception
    msg::String
end

function RedisException(redis_context::RedisContext)
    io = IOBuffer()
    errstr = [char for char in redis_context.errstr if char != 0]
    write(io, errstr)
    return RedisException(String(take!(io)))
end
