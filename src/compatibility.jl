function rat(value::Rational)
    BigInt(numerator(value)) // BigInt(denominator(value))
end

rat(value::Integer) = BigInt(value) // big(1)

function rat(n::Integer, d::Integer)
    d == 0 && throw(ArgumentError("denominator cannot be zero"))
    BigInt(n) // BigInt(d)
end

function rat(value::AbstractString)
    s = strip(value)
    isempty(s) && throw(ArgumentError("invalid rational format"))

    if occursin("..", s)
        parts = split(s, "..")
        length(parts) == 2 || throw(ArgumentError("invalid mixed number format"))
        whole = parse(BigInt, parts[1])
        frac = split(parts[2], "/")
        length(frac) == 2 || throw(ArgumentError("invalid mixed number fraction"))
        n = parse(BigInt, frac[1])
        d = parse(BigInt, frac[2])
        d == 0 && throw(ArgumentError("denominator cannot be zero"))
        sign = whole < 0 ? -1 : 1
        return (sign * (abs(whole) * d + n)) // d
    elseif occursin(".", s)
        count(==('.'), s) == 1 || throw(ArgumentError("invalid decimal format"))
        intpart, fracpart = split(s, ".")
        isempty(intpart) && (intpart = "0")
        occursin(r"^-?\d+$", intpart) || throw(ArgumentError("invalid decimal format"))
        occursin(r"^\d*$", fracpart) || throw(ArgumentError("invalid decimal format"))
        negative_decimal = startswith(intpart, "-")
        whole = parse(BigInt, intpart)
        scale = big(10) ^ length(fracpart)
        frac_value = isempty(fracpart) ? big(0) : parse(BigInt, fracpart)
        num = whole * scale + (negative_decimal ? -frac_value : frac_value)
        return num // scale
    elseif occursin("/", s)
        parts = split(s, "/")
        length(parts) == 2 || throw(ArgumentError("invalid rational format"))
        return rat(parse(BigInt, parts[1]), parse(BigInt, parts[2]))
    else
        return parse(BigInt, s) // big(1)
    end
end

function mixed(whole::Integer, n::Integer, d::Integer)
    d == 0 && throw(ArgumentError("denominator cannot be zero"))
    sign = whole < 0 ? -1 : 1
    (sign * (abs(BigInt(whole)) * BigInt(d) + BigInt(n))) // BigInt(d)
end

function exact_div(a::Integer, b::Integer)
    b == 0 && throw(DivideError())
    rem(a, b) == 0 ? BigInt(a) ÷ BigInt(b) : BigInt(a) // BigInt(b)
end

function reciprocal(x::Rational)
    numerator(x) == 0 && throw(DomainError(x, "cannot take reciprocal of zero"))
    denominator(x) // numerator(x)
end

function pow_exact(x::Integer, exponent::Integer)
    n = BigInt(exponent)
    x == 0 && n == 0 && throw(DomainError(x, "zero cannot be raised to the power of zero"))
    x == 0 && n < 0 && throw(DomainError(x, "zero cannot be raised to a negative power"))
    n >= 0 ? BigInt(x) ^ n : big(1) // (BigInt(x) ^ -n)
end

function pow_exact(x::Rational, exponent::Integer)
    n = BigInt(exponent)
    numerator(x) == 0 && n == 0 && throw(DomainError(x, "zero cannot be raised to the power of zero"))
    numerator(x) == 0 && n < 0 && throw(DomainError(x, "zero cannot be raised to a negative power"))
    n >= 0 ? rat(x) ^ n : reciprocal(rat(x)) ^ -n
end

function e_notation(x::Integer, exponent::Integer)
    exp = BigInt(exponent)
    exp >= 0 ? BigInt(x) * big(10)^exp : BigInt(x) // big(10)^(-exp)
end

function e_notation(x::Rational, exponent::Integer)
    exp = BigInt(exponent)
    multiplier = exp >= 0 ? big(10)^exp // big(1) : big(1) // big(10)^(-exp)
    rat(x) * multiplier
end

function bit_length(x::Integer)::Int
    n = abs(BigInt(x))
    n == 0 && return 0
    length(string(n, base=2))
end

function bit_length(x::Rational)::Int
    max(bit_length(numerator(x)), bit_length(denominator(x)))
end

function double_factorial(n::Integer)
    n < 0 && throw(DomainError(n, "double factorial is not defined for negative integers"))
    n == 0 || n == 1 ? big(1) : prod(BigInt(i) for i in BigInt(n):-big(2):big(1); init=big(1))
end

function to_mixed_string(x::Rational)
    r = rat(x)
    n = numerator(r)
    d = denominator(r)
    (d == 1 || n == 0) && return string(n)
    whole = abs(n) ÷ d
    remn = abs(n) % d
    sign = n < 0 ? "-" : ""
    whole == 0 ? "$(sign)$(remn)/$(d)" : "$(sign)$(whole)..$(remn)/$(d)"
end

function rational_string(x::Rational)::String
    r = rat(x)
    denominator(r) == 1 ? string(numerator(r)) : "$(numerator(r))/$(denominator(r))"
end
