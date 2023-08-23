module Hiredis

using hiredis_jll

export RedisClient, RedisException, disconnect!, ping, set, del, exists, expire, flushall

const Optional{T} = Union{T,Nothing} where {T}

include("wrappers.jl")
include("exceptions.jl")
include("client.jl")
include("commands.jl")

end
