const DEFAULT_CF_LIMIT = 1000

function from_continued_fraction(terms)::Rational{BigInt}
    isempty(terms) && throw(ArgumentError("continued fraction array cannot be empty"))
    cf = BigInt[]
    for (i, term) in enumerate(terms)
        value = BigInt(term)
        i > 1 && value <= 0 && throw(ArgumentError("continued fraction terms after the first must be positive"))
        push!(cf, value)
    end
    length(cf) == 1 && return cf[1] // big(1)

    p_prev = big(1)
    p_curr = cf[1]
    q_prev = big(0)
    q_curr = big(1)
    for a in cf[2:end]
        p_next = a * p_curr + p_prev
        q_next = a * q_curr + q_prev
        p_prev, p_curr = p_curr, p_next
        q_prev, q_curr = q_curr, q_next
    end
    p_curr // q_curr
end

function continued_fraction(x::Rational; max_terms::Integer=DEFAULT_CF_LIMIT)::Vector{BigInt}
    r = rat(x)
    n = numerator(r)
    d = denominator(r)
    cf = BigInt[]
    count = 0
    while d != 0 && count < max_terms
        a = fld(n, d)
        push!(cf, a)
        remn = n - a * d
        remn == 0 && break
        n, d = d, remn
        count += 1
    end
    if length(cf) > 1 && cf[end] == 1
        cf[end-1] += 1
        pop!(cf)
    end
    cf
end

function continued_fraction_string(x::Rational)::String
    cf = continued_fraction(x)
    length(cf) == 1 && return "$(cf[1]).~0"
    "$(cf[1]).~$(join(cf[2:end], "~"))"
end

function from_continued_fraction_string(s::AbstractString)::Rational{BigInt}
    m = match(r"^(-?\d+)\.~(.*)$", strip(s))
    isnothing(m) && throw(ArgumentError("invalid continued fraction format"))
    intpart = parse(BigInt, m.captures[1])
    rest = m.captures[2]
    rest == "0" && return intpart // big(1)
    isempty(rest) && throw(ArgumentError("continued fraction must have terms after .~"))
    endswith(rest, "~") && throw(ArgumentError("continued fraction cannot end with ~"))
    occursin("~~", rest) && throw(ArgumentError("invalid continued fraction format"))
    terms = BigInt[intpart]
    for part in split(rest, "~")
        occursin(r"^\d+$", part) || throw(ArgumentError("invalid continued fraction term"))
        value = parse(BigInt, part)
        value <= 0 && throw(ArgumentError("continued fraction terms must be positive"))
        push!(terms, value)
    end
    from_continued_fraction(terms)
end

function convergents(x::Rational; max_count::Integer=DEFAULT_CF_LIMIT)
    convergents_from_cf(continued_fraction(x; max_terms=max_count); max_count=max_count)
end

function convergents_from_cf(input; max_count::Integer=DEFAULT_CF_LIMIT)
    cf = input isa AbstractString ? continued_fraction(from_continued_fraction_string(input); max_terms=max_count) : BigInt[BigInt(t) for t in input]
    isempty(cf) && throw(ArgumentError("continued fraction array cannot be empty"))
    result = Rational{BigInt}[]
    p_prev = big(1)
    p_curr = cf[1]
    q_prev = big(0)
    q_curr = big(1)
    push!(result, p_curr // q_curr)
    for a in cf[2:min(end, max_count)]
        p_next = a * p_curr + p_prev
        q_next = a * q_curr + q_prev
        push!(result, p_next // q_next)
        p_prev, p_curr = p_curr, p_next
        q_prev, q_curr = q_curr, q_next
    end
    result
end

function get_convergent(x::Rational, n::Integer)
    convs = convergents(x)
    0 <= n < length(convs) || throw(BoundsError(convs, n))
    convs[Int(n) + 1]
end

approximation_error(x::Rational, target::Rational) = abs(rat(x) - rat(target))

function best_approximation(x::Rational, max_denominator::Integer)
    best = first(convergents(x))
    for c in convergents(x)
        denominator(c) <= max_denominator ? (best = c) : break
    end
    best
end
