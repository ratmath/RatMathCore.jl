struct RationalInterval
    start::Rational{BigInt}
    stop::Rational{BigInt}
    low::Rational{BigInt}
    high::Rational{BigInt}

    function RationalInterval(a, b)
        ar = rat(a)
        br = rat(b)
        ar <= br ? new(ar, br, ar, br) : new(ar, br, br, ar)
    end
end

point_interval(x) = RationalInterval(x, x)

function parse_interval(s::AbstractString)
    parts = split(strip(s), ":")
    length(parts) == 2 || throw(ArgumentError("invalid interval format"))
    RationalInterval(rat(parts[1]), rat(parts[2]))
end

Base.:(==)(a::RationalInterval, b::RationalInterval) = a.low == b.low && a.high == b.high
Base.string(i::RationalInterval) = "$(rational_string(i.start)):$(rational_string(i.stop))"
Base.show(io::IO, i::RationalInterval) = print(io, string(i))

_interval(x::RationalInterval) = x
_interval(x) = point_interval(x)

function +(a::RationalInterval, b::RationalInterval)
    RationalInterval(a.low + b.low, a.high + b.high)
end

function +(a::RationalInterval, b)
    bi = _interval(b)
    RationalInterval(a.low + bi.low, a.high + bi.high)
end
+(a, b::RationalInterval) = b + a

function -(a::RationalInterval, b::RationalInterval)
    RationalInterval(a.low - b.high, a.high - b.low)
end

function -(a::RationalInterval, b)
    bi = _interval(b)
    RationalInterval(a.low - bi.high, a.high - bi.low)
end
-(a, b::RationalInterval) = _interval(a) - b
-(a::RationalInterval) = RationalInterval(-a.high, -a.low)

function *(a::RationalInterval, b::RationalInterval)
    products = [a.low * b.low, a.low * b.high, a.high * b.low, a.high * b.high]
    RationalInterval(minimum(products), maximum(products))
end

function *(a::RationalInterval, b)
    bi = _interval(b)
    products = [a.low * bi.low, a.low * bi.high, a.high * bi.low, a.high * bi.high]
    RationalInterval(minimum(products), maximum(products))
end
*(a, b::RationalInterval) = b * a

function /(a::RationalInterval, b::RationalInterval)
    contains_zero(b) && throw(DomainError(b, "cannot divide by an interval containing zero"))
    quotients = [a.low / b.low, a.low / b.high, a.high / b.low, a.high / b.high]
    RationalInterval(minimum(quotients), maximum(quotients))
end

function /(a::RationalInterval, b)
    bi = _interval(b)
    contains_zero(bi) && throw(DomainError(bi, "cannot divide by an interval containing zero"))
    quotients = [a.low / bi.low, a.low / bi.high, a.high / bi.low, a.high / bi.high]
    RationalInterval(minimum(quotients), maximum(quotients))
end
/(a, b::RationalInterval) = _interval(a) / b

contains_zero(i::RationalInterval) = i.low <= 0//1 <= i.high
Base.in(x, i::RationalInterval) = i.low <= rat(x) <= i.high
overlaps(a::RationalInterval, b::RationalInterval) = !(a.high < b.low || b.high < a.low)
Base.contains(i::RationalInterval, x) = x isa RationalInterval ? (i.low <= x.low && i.high >= x.high) : (rat(x) in i)

function intersection(a::RationalInterval, b::RationalInterval)
    overlaps(a, b) || return nothing
    RationalInterval(max(a.low, b.low), min(a.high, b.high))
end

function union(a::RationalInterval, b::RationalInterval)
    (overlaps(a, b) || a.high == b.low || b.high == a.low) || return nothing
    RationalInterval(min(a.low, b.low), max(a.high, b.high))
end

function reciprocal(i::RationalInterval)
    contains_zero(i) && throw(DomainError(i, "cannot reciprocate an interval containing zero"))
    RationalInterval(reciprocal(i.high), reciprocal(i.low))
end

midpoint(i::RationalInterval) = (i.low + i.high) / 2
mediant(i::RationalInterval) = (numerator(i.low) + numerator(i.high)) // (denominator(i.low) + denominator(i.high))

function pow_interval(i::RationalInterval, exponent::Integer)
    n = BigInt(exponent)
    if n == 0
        contains_zero(i) && throw(DomainError(i, "cannot raise interval containing zero to zero"))
        return point_interval(1)
    elseif n < 0
        contains_zero(i) && throw(DomainError(i, "cannot raise interval containing zero to negative power"))
        return reciprocal(pow_interval(i, -n))
    elseif n == 1
        return RationalInterval(i.low, i.high)
    elseif iseven(n)
        lowpow = pow_exact(i.low, n)
        highpow = pow_exact(i.high, n)
        if contains_zero(i)
            return RationalInterval(0, max(abs(lowpow), abs(highpow)))
        elseif i.high < 0
            return RationalInterval(highpow, lowpow)
        else
            return RationalInterval(lowpow, highpow)
        end
    else
        RationalInterval(pow_exact(i.low, n), pow_exact(i.high, n))
    end
end

function mpow_interval(i::RationalInterval, exponent::Integer)
    n = BigInt(exponent)
    n == 0 && throw(DomainError(i, "multiplicative exponentiation requires at least one factor"))
    n < 0 && return mpow_interval(reciprocal(i), -n)
    result = RationalInterval(i.low, i.high)
    for _ in 2:n
        result = result * i
    end
    result
end

function bit_length(i::RationalInterval)
    max(bit_length(i.low), bit_length(i.high))
end

function to_mixed_string(i::RationalInterval)
    "$(to_mixed_string(i.start)):$(to_mixed_string(i.stop))"
end

function repeating_decimal(i::RationalInterval; compact::Bool=true)
    "$(repeating_decimal(i.start; compact=compact)):$(repeating_decimal(i.stop; compact=compact))"
end

function compacted_decimal_interval(i::RationalInterval)::String
    start_str = to_decimal(i.start)
    stop_str = to_decimal(i.stop)
    common = IOBuffer()
    limit = min(length(start_str), length(stop_str))
    for idx in 1:limit
        start_str[idx] == stop_str[idx] || break
        print(common, start_str[idx])
    end
    prefix = String(take!(common))
    if length(prefix) <= 1 || (startswith(prefix, "-") && length(prefix) <= 2)
        return "$start_str:$stop_str"
    end
    suffix_start = length(prefix) + 1
    start_suffix = suffix_start <= length(start_str) ? start_str[suffix_start:end] : ""
    stop_suffix = suffix_start <= length(stop_str) ? stop_str[suffix_start:end] : ""
    if isempty(start_suffix) || isempty(stop_suffix) || length(start_suffix) != length(stop_suffix)
        return "$start_str:$stop_str"
    end
    occursin(r"^\d+$", start_suffix) && occursin(r"^\d+$", stop_suffix) || return "$start_str:$stop_str"
    "$prefix[$start_suffix,$stop_suffix]"
end

function relative_mid_decimal_interval(i::RationalInterval)::String
    mid = midpoint(i)
    offset_start = i.start - mid
    offset_stop = i.stop - mid
    mid_str = to_decimal(mid)
    if offset_start == -offset_stop
        return "$mid_str[+-$(to_decimal(abs(offset_stop)))]"
    end
    start_str = to_decimal(offset_start)
    stop_str = to_decimal(offset_stop)
    start_prefix = offset_start > 0 ? "+" : ""
    stop_prefix = offset_stop > 0 ? "+" : ""
    "$mid_str[$start_prefix$start_str,$stop_prefix$stop_str]"
end

function relative_decimal_interval(i::RationalInterval)::String
    base_value = shortest_decimal(i)
    isnothing(base_value) && return relative_mid_decimal_interval(i)
    offset_start = i.start - base_value
    offset_stop = i.stop - base_value
    base_str = to_decimal(base_value)
    decimal_places = occursin(".", base_str) ? length(split(base_str, ".")[2]) : 0
    scale_factor = decimal_places == 0 ? big(1)//big(1) : big(10)^(decimal_places + 1)//big(1)
    scaled_start = offset_start * scale_factor
    scaled_stop = offset_stop * scale_factor
    if abs(offset_start + offset_stop) < 1//1_000_000
        avg = (abs(scaled_start) + abs(scaled_stop)) / 2
        return "$base_str[+-$(to_decimal(avg))]"
    end
    first_offset, second_offset = scaled_start >= scaled_stop ? (scaled_start, scaled_stop) : (scaled_stop, scaled_start)
    "$base_str[+$(to_decimal(abs(first_offset))),-$(to_decimal(abs(second_offset)))]"
end

function e_notation(i::RationalInterval, exponent::Integer)
    factor = e_notation(1, exponent)
    RationalInterval(i.low * factor, i.high * factor)
end

function rational_interval(i::FractionInterval)
    RationalInterval(rational(i.low), rational(i.high))
end

function fraction_interval(i::RationalInterval)
    FractionInterval(Fraction(numerator(i.low), denominator(i.low)), Fraction(numerator(i.high), denominator(i.high)))
end

function shortest_decimal(i::RationalInterval; base::Integer=10)
    b = BigInt(base)
    b > 1 || throw(ArgumentError("base must be greater than 1"))
    if i.low == i.high
        den = big(1)
        for _ in 0:50
            candidate = i.low * den
            denominator(candidate) == 1 && return numerator(candidate) // den
            den *= b
        end
        return nothing
    end

    den = big(1)
    for _ in 0:256
        min_num = ceil(Integer, i.low * den)
        max_num = floor(Integer, i.high * den)
        min_num <= max_num && return BigInt(min_num) // den
        den *= b
    end
    throw(ArgumentError("failed to find shortest decimal representation"))
end

function random_rational(i::RationalInterval; max_denominator::Integer=1000, rng=nothing)
    max_denominator > 0 || throw(ArgumentError("max_denominator must be positive"))
    candidates = Rational{BigInt}[]
    for den in big(1):BigInt(max_denominator)
        min_num = ceil(Integer, i.low * den)
        max_num = floor(Integer, i.high * den)
        for num in min_num:max_num
            c = BigInt(num) // den
            numerator(c) == num && denominator(c) == den && push!(candidates, c)
        end
    end
    isempty(candidates) && return midpoint(i)
    isnothing(rng) ? rand(candidates) : rand(rng, candidates)
end
