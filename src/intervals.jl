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
