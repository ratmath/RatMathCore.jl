struct Fraction
    num::BigInt
    den::BigInt
    infinite::Bool

    function Fraction(n::Integer, d::Integer=1; allow_infinite::Bool=false)
        num = BigInt(n)
        den = BigInt(d)
        if den == 0
            allow_infinite && (num == 1 || num == -1) || throw(ArgumentError("denominator cannot be zero"))
            return new(num, den, true)
        end
        new(num, den, false)
    end
end

function Fraction(s::AbstractString; allow_infinite::Bool=false)
    parts = split(strip(s), "/")
    if length(parts) == 1
        Fraction(parse(BigInt, parts[1]), 1; allow_infinite=allow_infinite)
    elseif length(parts) == 2
        Fraction(parse(BigInt, parts[1]), parse(BigInt, parts[2]); allow_infinite=allow_infinite)
    else
        throw(ArgumentError("invalid fraction format"))
    end
end

Base.:(==)(a::Fraction, b::Fraction) = a.num == b.num && a.den == b.den && a.infinite == b.infinite
Base.hash(f::Fraction, h::UInt) = hash((f.num, f.den, f.infinite), h)

function Base.isless(a::Fraction, b::Fraction)
    a.infinite && b.infinite && return a.num < b.num
    a.infinite && return a.num < 0
    b.infinite && return b.num > 0
    a.num * b.den < a.den * b.num
end

Base.:<(a::Fraction, b::Fraction) = isless(a, b)
Base.:<=(a::Fraction, b::Fraction) = a == b || a < b

function Base.show(io::IO, f::Fraction)
    print(io, string(f))
end

function Base.string(f::Fraction)
    f.den == 1 ? string(f.num) : "$(f.num)/$(f.den)"
end

function +(a::Fraction, b::Fraction)
    a.den == b.den || throw(ArgumentError("addition only supported for equal denominators"))
    Fraction(a.num + b.num, a.den)
end

function -(a::Fraction, b::Fraction)
    a.den == b.den || throw(ArgumentError("subtraction only supported for equal denominators"))
    Fraction(a.num - b.num, a.den)
end

*(a::Fraction, b::Fraction) = Fraction(a.num * b.num, a.den * b.den)

function /(a::Fraction, b::Fraction)
    b.num == 0 && throw(DivideError())
    Fraction(a.num * b.den, a.den * b.num)
end

function pow_exact(f::Fraction, exponent::Integer)
    n = BigInt(exponent)
    f.num == 0 && n == 0 && throw(DomainError(f, "zero cannot be raised to the power of zero"))
    f.num == 0 && n < 0 && throw(DomainError(f, "zero cannot be raised to a negative power"))
    n >= 0 ? Fraction(f.num^n, f.den^n) : Fraction(f.den^(-n), f.num^(-n))
end

scale(f::Fraction, factor::Integer) = Fraction(f.num * BigInt(factor), f.den * BigInt(factor))

function reduce_fraction(f::Fraction)
    f.infinite && return f
    f.num == 0 && return Fraction(0, 1)
    g = gcd(f.num, f.den)
    n = f.num ÷ g
    d = f.den ÷ g
    d < 0 ? Fraction(-n, -d) : Fraction(n, d)
end

rational(f::Fraction) = f.infinite ? throw(ArgumentError("infinite fraction cannot convert to rational")) : f.num // f.den
e_notation(f::Fraction, exponent::Integer) = exponent >= 0 ? Fraction(f.num * big(10)^BigInt(exponent), f.den) : Fraction(f.num, f.den * big(10)^(-BigInt(exponent)))

function mediant(a::Fraction, b::Fraction)
    if a.infinite && b.infinite
        a.num == -b.num && return Fraction(0, 1)
        throw(ArgumentError("cannot compute mediant of two infinite fractions"))
    end
    n = a.num + b.num
    d = a.den + b.den
    n == 0 && d == 0 && throw(ArgumentError("mediant would result in 0/0"))
    Fraction(n, d)
end

function farey_parents(f::Fraction)
    f.infinite && throw(ArgumentError("cannot find Farey parents of infinite fraction"))
    target = reduce_fraction(f)
    if target == Fraction(0, 1)
        return (left=Fraction(-1, 0; allow_infinite=true), right=Fraction(1, 0; allow_infinite=true))
    end
    left = Fraction(-1, 0; allow_infinite=true)
    right = Fraction(1, 0; allow_infinite=true)
    current = Fraction(0, 1)
    while current != target
        if target < current
            right = current
            current = mediant(left, current)
        else
            left = current
            current = mediant(current, right)
        end
    end
    (left=left, right=right)
end

function mediant_partner(endpoint::Fraction, med::Fraction)
    endpoint.infinite || med.infinite && throw(ArgumentError("cannot compute mediant partner with infinite fractions"))
    r = med.num * 2 - endpoint.num
    s = med.den * 2 - endpoint.den
    Fraction(r, s)
end

function is_mediant_triple(left::Fraction, med::Fraction, right::Fraction)::Bool
    med.infinite && return false
    try
        mediant(left, right) == med
    catch
        false
    end
end

function is_farey_triple(left::Fraction, med::Fraction, right::Fraction)::Bool
    is_mediant_triple(left, med, right) || return false
    (left.infinite || right.infinite) && return true
    det = left.num * right.den - left.den * right.num
    det == 1 || det == -1
end

function stern_brocot_path(f::Fraction)
    f.infinite && throw(ArgumentError("infinite fractions do not have tree paths"))
    target = reduce_fraction(f)
    target == Fraction(0, 1) && return Char[]
    left = Fraction(-1, 0; allow_infinite=true)
    right = Fraction(1, 0; allow_infinite=true)
    current = Fraction(0, 1)
    path = Char[]
    while current != target
        if target < current
            push!(path, 'L')
            right = current
            current = mediant(left, current)
        else
            push!(path, 'R')
            left = current
            current = mediant(current, right)
        end
        length(path) > 500 && throw(ArgumentError("Stern-Brocot path too long"))
    end
    path
end

stern_brocot_string(f::Fraction) = join(stern_brocot_path(f))

function from_stern_brocot_path(path)::Fraction
    left = Fraction(-1, 0; allow_infinite=true)
    right = Fraction(1, 0; allow_infinite=true)
    current = Fraction(0, 1)
    for direction in path
        if direction == 'L' || direction == "L"
            right = current
            current = mediant(left, current)
        elseif direction == 'R' || direction == "R"
            left = current
            current = mediant(current, right)
        else
            throw(ArgumentError("invalid Stern-Brocot direction: $direction"))
        end
    end
    current
end

function stern_brocot_parent(f::Fraction)
    f.infinite && throw(ArgumentError("infinite fractions do not have parents"))
    path = stern_brocot_path(f)
    isempty(path) && return nothing
    from_stern_brocot_path(path[1:end-1])
end

function stern_brocot_children(f::Fraction)
    f.infinite && throw(ArgumentError("infinite fractions do not have children"))
    path = stern_brocot_path(f)
    (left=from_stern_brocot_path(vcat(path, ['L'])), right=from_stern_brocot_path(vcat(path, ['R'])))
end

stern_brocot_depth(f::Fraction) = f.infinite ? Inf : length(stern_brocot_path(f))

function stern_brocot_ancestors(f::Fraction)
    f.infinite && return Fraction[]
    path = stern_brocot_path(f)
    ancestors = [from_stern_brocot_path(path[1:i-1]) for i in 1:length(path)]
    reverse(ancestors)
end

struct FractionInterval
    low::Fraction
    high::Fraction

    function FractionInterval(a::Fraction, b::Fraction)
        a <= b ? new(a, b) : new(b, a)
    end
end

Base.:(==)(a::FractionInterval, b::FractionInterval) = a.low == b.low && a.high == b.high
Base.string(i::FractionInterval) = "$(string(i.low)):$(string(i.high))"
Base.show(io::IO, i::FractionInterval) = print(io, string(i))

function mediant_split(i::FractionInterval)
    m = mediant(i.low, i.high)
    (FractionInterval(i.low, m), FractionInterval(m, i.high))
end

function partition_with_mediants(i::FractionInterval, depth::Integer=1)
    depth < 0 && throw(ArgumentError("depth must be non-negative"))
    intervals = [i]
    for _ in 1:depth
        next = FractionInterval[]
        for interval in intervals
            append!(next, collect(mediant_split(interval)))
        end
        intervals = next
    end
    intervals
end

function partition_with(i::FractionInterval, fn)
    points = fn(i.low, i.high)
    points isa AbstractVector || throw(ArgumentError("partition function must return a vector"))
    all(p -> p isa Fraction, points) || throw(ArgumentError("partition points must be Fraction objects"))
    allpoints = sort([i.low; points; i.high])
    first(allpoints) == i.low && last(allpoints) == i.high || throw(ArgumentError("partition points should be within the interval"))
    unique_points = unique(allpoints)
    [FractionInterval(unique_points[j], unique_points[j+1]) for j in 1:length(unique_points)-1]
end

e_notation(i::FractionInterval, exponent::Integer) = FractionInterval(e_notation(i.low, exponent), e_notation(i.high, exponent))
