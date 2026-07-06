const RESERVED_BASE_SYMBOLS = Set(["+", "-", "*", "/", "^", "!", "(", ")", "[", "]", ":", ".", "#", "~"])

struct BaseSystem
    chars::Vector{String}
    charmap::Dict{String,Int}
    name::String

    function BaseSystem(characters, name::AbstractString="")
        chars = if characters isa AbstractString
            [string(c) for c in collect(characters)]
        elseif characters isa AbstractVector
            [string(c) for c in characters]
        else
            throw(ArgumentError("characters must be a string or vector"))
        end

        length(chars) >= 2 || throw(ArgumentError("base system must have at least two characters"))
        length(unique(chars)) == length(chars) || throw(ArgumentError("character set contains duplicate characters"))

        conflicts = [c for c in chars if c in RESERVED_BASE_SYMBOLS]
        isempty(conflicts) || throw(ArgumentError("base system characters conflict with parser symbols: $(join(conflicts, ", "))"))

        charmap = Dict{String,Int}()
        for (i, c) in enumerate(chars)
            charmap[c] = i - 1
        end

        system_name = isempty(name) ? "Base $(length(chars))" : String(name)
        new(chars, charmap, system_name)
    end
end

Base.length(system::BaseSystem) = length(system.chars)
Base.getproperty(system::BaseSystem, name::Symbol) = name === :base ? length(getfield(system, :chars)) : getfield(system, name)

function get_char(system::BaseSystem, value::Integer)
    i = Int(value)
    0 <= i < system.base || throw(BoundsError(system.chars, i))
    system.chars[i + 1]
end

function to_decimal(system::BaseSystem, s::AbstractString)::BigInt
    isempty(s) && throw(ArgumentError("input must be non-empty"))
    negative = startswith(s, "-")
    digits = negative ? s[2:end] : s
    isempty(digits) && throw(ArgumentError("input must contain digits"))

    result = big(0)
    base_value = BigInt(system.base)
    for c in collect(digits)
        ch = string(c)
        haskey(system.charmap, ch) || throw(ArgumentError("invalid character '$ch' for $(system.name)"))
        result = result * base_value + BigInt(system.charmap[ch])
    end
    negative ? -result : result
end

function from_decimal(system::BaseSystem, value::Integer)::String
    n = BigInt(value)
    n == 0 && return system.chars[1]

    negative = n < 0
    n = abs(n)
    base_value = BigInt(system.base)
    digits = String[]
    while n > 0
        rem_digit = n % base_value
        pushfirst!(digits, get_char(system, rem_digit))
        n ÷= base_value
    end
    result = join(digits)
    negative ? "-" * result : result
end

to_base(value::Integer, system::BaseSystem)::String = from_decimal(system, value)
to_base(value::Integer, base::Integer)::String = to_base(value, base_system(base))

function to_base(value::Rational, system::BaseSystem; repeating::Bool=false)::String
    repeating && return repeating_base(value, system)
    r = rat(value)
    num_str = from_decimal(system, numerator(r))
    denominator(r) == 1 && return num_str
    den_str = from_decimal(system, denominator(r))
    "$num_str/$den_str"
end

to_base(value::Rational, base::Integer; repeating::Bool=false)::String = to_base(value, base_system(base); repeating=repeating)

function valid_digit_string(system::BaseSystem, s::AbstractString)::Bool
    isempty(s) && return false
    digits = startswith(s, "-") ? s[2:end] : s
    isempty(digits) && return false
    all(c -> haskey(system.charmap, string(c)), collect(digits))
end

function Base.:(==)(a::BaseSystem, b::BaseSystem)
    a.chars == b.chars
end

function Base.hash(system::BaseSystem, h::UInt)
    hash(system.chars, h)
end

function Base.show(io::IO, system::BaseSystem)
    preview = length(system.chars) <= 20 ? join(system.chars) : join(system.chars[1:10]) * "..." * join(system.chars[end-9:end])
    print(io, "$(system.name) ($preview)")
end

function base_system(base::Integer; name=nothing)::BaseSystem
    b = Int(base)
    b >= 2 || throw(ArgumentError("base must be an integer >= 2"))
    b <= 62 || throw(ArgumentError("base_system only supports bases up to 62; use BaseSystem with custom characters for larger bases"))

    chars = String[]
    for i in 0:min(b, 10)-1
        push!(chars, string(Char(Int('0') + i)))
    end
    if b > 10
        for i in 0:min(b - 10, 26)-1
            push!(chars, string(Char(Int('a') + i)))
        end
    end
    if b > 36
        for i in 0:b-37
            push!(chars, string(Char(Int('A') + i)))
        end
    end
    BaseSystem(chars, isnothing(name) ? "Base $b" : String(name))
end

function create_base_pattern(pattern::Symbol, size::Integer; name=nothing)::BaseSystem
    n = Int(size)
    n >= 2 || throw(ArgumentError("size must be at least 2"))
    if pattern === :alphanumeric
        n <= 62 || throw(ArgumentError("alphanumeric pattern only supports up to base 62"))
        return base_system(n; name=name)
    elseif pattern === :digits_only
        n <= 10 || throw(ArgumentError("digits-only pattern only supports up to base 10"))
        return BaseSystem([string(Char(Int('0') + i)) for i in 0:n-1], isnothing(name) ? "Base $n (digits only)" : String(name))
    elseif pattern === :letters_only
        n <= 52 || throw(ArgumentError("letters-only pattern only supports up to base 52"))
        chars = String[]
        for i in 0:min(n, 26)-1
            push!(chars, string(Char(Int('a') + i)))
        end
        if n > 26
            for i in 0:n-27
                push!(chars, string(Char(Int('A') + i)))
            end
        end
        return BaseSystem(chars, isnothing(name) ? "Base $n (letters only)" : String(name))
    elseif pattern === :uppercase_only
        n <= 26 || throw(ArgumentError("uppercase-only pattern only supports up to base 26"))
        return BaseSystem([string(Char(Int('A') + i)) for i in 0:n-1], isnothing(name) ? "Base $n (uppercase letters)" : String(name))
    end
    throw(ArgumentError("unknown base pattern: $pattern"))
end

function with_case_sensitivity(system::BaseSystem, case_sensitive::Bool)::BaseSystem
    case_sensitive && return system
    BaseSystem(unique(lowercase.(system.chars)), "$(system.name) (case-insensitive)")
end

const BINARY = BaseSystem(["0", "1"], "Binary")
const TERNARY = BaseSystem(["0", "1", "2"], "Ternary")
const QUATERNARY = BaseSystem(["0", "1", "2", "3"], "Quaternary")
const QUINARY = BaseSystem(["0", "1", "2", "3", "4"], "Quinary (Base 5)")
const SEPTENARY = BaseSystem(["0", "1", "2", "3", "4", "5", "6"], "Septenary (Base 7)")
const OCTAL = BaseSystem(["0", "1", "2", "3", "4", "5", "6", "7"], "Octal")
const DECIMAL = BaseSystem(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], "Decimal")
const DUODECIMAL = BaseSystem(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b"], "Duodecimal (Clock/Base 12)")
const HEXADECIMAL = BaseSystem(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"], "Hexadecimal")
const VIGESIMAL = BaseSystem("0123456789abcdefghij", "Vigesimal (Base 20)")
const BASE36 = BaseSystem("0123456789abcdefghijklmnopqrstuvwxyz", "Base 36 (URL)")
const BASE60 = BaseSystem("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX", "Base 60 (Mesopotamia)")
const BASE62 = BaseSystem("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "Base 62")
const BASE64 = BaseSystem("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@&", "Base 64")
const ROMAN = BaseSystem(["I", "V", "X", "L", "C", "D", "M"], "Roman Numerals")

const PREFIX_MAP = Dict{String,BaseSystem}()

function register_prefix!(prefix::AbstractString, system::BaseSystem)
    length(prefix) == 1 || throw(ArgumentError("prefix must be a single character"))
    occursin(r"^[A-Za-z]$", prefix) || throw(ArgumentError("prefix must be a letter"))
    PREFIX_MAP[String(prefix)] = system
    system
end

function unregister_prefix!(prefix::AbstractString)
    pop!(PREFIX_MAP, String(prefix), nothing)
    nothing
end

function system_for_prefix(prefix::AbstractString)
    p = String(prefix)
    p == "D" && return nothing
    haskey(PREFIX_MAP, p) && return PREFIX_MAP[p]
    lower = lowercase(p)
    if haskey(PREFIX_MAP, lower)
        lower == "d" && p != "d" && return nothing
        return PREFIX_MAP[lower]
    end
    nothing
end

function prefix_for_system(system::BaseSystem)
    for (prefix, registered) in PREFIX_MAP
        registered == system && return prefix
    end
    nothing
end

function __init_base_prefixes__()
    isempty(PREFIX_MAP) || return
    register_prefix!("b", BINARY)
    register_prefix!("t", TERNARY)
    register_prefix!("q", QUATERNARY)
    register_prefix!("f", QUINARY)
    register_prefix!("s", SEPTENARY)
    register_prefix!("o", OCTAL)
    register_prefix!("d", DUODECIMAL)
    register_prefix!("x", HEXADECIMAL)
    register_prefix!("v", VIGESIMAL)
    register_prefix!("u", BASE36)
    register_prefix!("m", BASE60)
    register_prefix!("y", BASE64)
end

__init_base_prefixes__()
