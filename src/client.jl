struct RedisClient
    host::String
    port::Int
    redis_context_pointer::Ptr{RedisContext}
    ssl_context_pointer::Optional{Ptr{SSLContext}}
end

function RedisClient(;
    host::AbstractString,
    port::Int,
    password::AbstractString = "",
    ssl::Bool = false,
    cacert_filename::AbstractString = "",
    capath::AbstractString = "",
    cert_filename::AbstractString = "",
    private_key_filename::AbstractString = "",
    server_name::AbstractString = "",
)
    redis_context_pointer = GC.@preserve @ccall libhiredis_ssl.redisConnect(
        host::Cstring,
        port::Cint,
    )::Ptr{RedisContext}

    ssl_context_pointer::Optional{Ptr{SSLContext}} = nothing

    if ssl
        @ccall libhiredis_ssl.redisInitOpenSSL()::Cvoid

        ssl_context_pointer = GC.@preserve @ccall libhiredis_ssl.redisCreateSSLContext(
            (isempty(cacert_filename) ? C_NULL : cacert_filename)::Cstring,
            (isempty(capath) ? C_NULL : capath)::Cstring,
            (isempty(cert_filename) ? C_NULL : cert_filename)::Cstring,
            (isempty(private_key_filename) ? C_NULL : private_key_filename)::Cstring,
            (isempty(server_name) ? C_NULL : server_name)::Cstring,
            0::Cint,
        )::Ptr{SSLContext}

        status = @ccall libhiredis_ssl.redisInitiateSSLWithContext(
            redis_context_pointer::Ptr{RedisContext},
            ssl_context_pointer::Ptr{SSLContext},
        )::Cint

        redis_context = unsafe_load(redis_context_pointer)
        status == 0 || throw(RedisException(redis_context))
    end

    if !isempty(password)
        redis_reply_pointer = @ccall libhiredis_ssl.redisCommand(
            redis_context_pointer::Ptr{RedisContext},
            "AUTH $password"::Cstring,
        )::Ptr{RedisReply}

        @ccall libhiredis_ssl.freeReplyObject(redis_reply_pointer::Ptr{RedisReply})::Cvoid
    end

    redis_context = unsafe_load(redis_context_pointer)
    redis_context.err != 0 && throw(RedisException(redis_context))

    return RedisClient(host, port, redis_context_pointer, ssl_context_pointer)
end

Base.show(io::IO, client::RedisClient) =
    print(io, "RedisClient(host=\"$(client.host)\", port=$(client.port))")

function disconnect!(client::RedisClient)
    @ccall libhiredis_ssl.redisFree(client.redis_context_pointer::Ptr{RedisContext})::Cvoid

    if !isnothing(client.ssl_context_pointer)
        @ccall libhiredis_ssl.redisFreeSSLContext(
            client.ssl_context_pointer::Ptr{SSLContext},
        )::Cvoid
    end
end

function execute_command(client::RedisClient, command::String, ::Type{T})::T where {T}
    redis_reply_pointer = @ccall libhiredis_ssl.redisCommand(
        client.redis_context_pointer::Ptr{RedisContext},
        command::Cstring,
    )::Ptr{RedisReply}

    redis_context = unsafe_load(client.redis_context_pointer)
    redis_context.err == 0 || throw(RedisException(redis_context))

    redis_reply = unsafe_load(redis_reply_pointer)
    response_value::T = extract_response_value(T, redis_reply)

    @ccall libhiredis_ssl.freeReplyObject(redis_reply_pointer::Ptr{RedisReply})::Cvoid
    return response_value
end

extract_response_value(::Type{Nothing}, reply::RedisReply) = nothing
extract_response_value(::Type{Int}, reply::RedisReply) = reply.integer
extract_response_value(::Type{String}, reply::RedisReply) =
    reply.str != C_NULL ? unsafe_string(reply.str) : throw(RedisException("No value found"))
