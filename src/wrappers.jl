struct RedisReply
    type::Cint
    integer::Clonglong
    dval::Cdouble
    len::Csize_t
    str::Cstring
    vtype::NTuple{4,Cchar}
    elements::Csize_t
    element::Tuple{Ptr{RedisReply}}
end

struct SSLContext
    context::Ptr{Cvoid}
end

struct TCP
    host::Ptr{Cchar}
    source_addr::Ptr{Cchar}
    port::Cint
end

struct UnixSock
    path::Ptr{Cchar}
end

struct RedisContextFuncs
    close::Ptr{Cvoid}
    free_privctx::Ptr{Cvoid}
    async_read::Ptr{Cvoid}
    async_write::Ptr{Cvoid}
    read::Cssize_t
    write::Cssize_t
end

struct Timeval
    tv_sec::Clong
    tv_usec::Clong
end

struct RedisContext
    funcs::Ptr{RedisContextFuncs}
    err::Cint
    errstr::NTuple{128,Cchar}
    fd::Cint
    flags::Cint
    flags_padding::Cint
    obuf::Ptr{Cchar}
    reader::Ptr{Cvoid}
    connection_type::Cint
    connection_type_padding::Cint
    connect_timeout::Ptr{Timeval}
    command_timout::Ptr{Timeval}
    tcp::TCP
    unix_sock::UnixSock
    sockaddr::Ptr{Cvoid}
    addrlen::Csize_t
    privdata::Ptr{Cvoid}
    free_privdata::Ptr{Cvoid}
    privctx::Ptr{Cvoid}
    push_cb::Ptr{Cvoid}
end
