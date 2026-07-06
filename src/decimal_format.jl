function _format_repeated_digits(digits::AbstractString; threshold::Integer=6)::String
    isempty(digits) && return String(digits)
    result = IOBuffer()
    i = firstindex(digits)
    while i <= lastindex(digits)
        c = digits[i]
        count = 1
        j = nextind(digits, i)
        while j <= lastindex(digits) && digits[j] == c
            count += 1
            j = nextind(digits, j)
        end
        if count > threshold
            print(result, "{$c~$count}")
        else
            print(result, repeat(string(c), count))
        end
        i = j
    end
    String(take!(result))
end

function to_decimal(x::Rational; maxdigits::Integer=20)::String
    r = rat(x)
    numerator(r) == 0 && return "0"
    negative = numerator(r) < 0
    n = abs(numerator(r))
    d = denominator(r)
    whole = n ÷ d
    remn = n % d
    remn == 0 && return (negative ? "-" : "") * string(whole)
    digits = String[]
    for _ in 1:maxdigits
        remn == 0 && break
        remn *= 10
        push!(digits, string(remn ÷ d))
        remn %= d
    end
    (negative ? "-" : "") * string(whole) * "." * join(digits)
end

function repeating_decimal(x::Rational; compact::Bool=true)::String
    repeating_decimal_with_period(x; compact=compact).decimal
end

function repeating_decimal_with_period(x::Rational; compact::Bool=true)
    repeating_base_with_period(x, DECIMAL; compact=compact, limit=1000, terminating_hash_for_integers=false)
end

function repeating_base(x::Rational, system::BaseSystem; compact::Bool=true, limit::Integer=1000)::String
    repeating_base_with_period(x, system; compact=compact, limit=limit).base_string
end

function repeating_base_with_period(
    x::Rational,
    system::BaseSystem;
    compact::Bool=true,
    limit::Integer=1000,
    terminating_hash_for_integers::Bool=true,
)
    r = rat(x)
    if numerator(r) < 0
        inner = repeating_base_with_period(-r, system; compact=compact, limit=limit, terminating_hash_for_integers=terminating_hash_for_integers)
        return (base_string="-" * inner.base_string, decimal="-" * get(inner, :decimal, inner.base_string), period=inner.period, limit_hit=inner.limit_hit)
    end

    n = numerator(r)
    d = denominator(r)
    whole = n ÷ d
    remn = n % d
    result = from_decimal(system, whole)

    if remn == 0
        display = terminating_hash_for_integers ? result * "#0" : result
        return (base_string=display, decimal=display, period=0, limit_hit=false)
    end

    seen = Dict{BigInt,Int}()
    digits = String[]
    cycle_start = 0
    limit_hit = false
    base_value = BigInt(system.base)

    while remn != 0
        if haskey(seen, remn)
            cycle_start = seen[remn]
            break
        end
        if length(digits) >= limit
            limit_hit = true
            break
        end
        seen[remn] = length(digits) + 1
        remn *= base_value
        digit = remn ÷ d
        push!(digits, get_char(system, digit))
        remn %= d
    end

    result *= "."
    if cycle_start > 0
        nonrepeating = join(digits[1:cycle_start-1])
        repeating = join(digits[cycle_start:end])
        nonrepeating = compact ? _format_repeated_digits(nonrepeating) : nonrepeating
        repeating = compact ? _format_repeated_digits(repeating) : repeating
        result *= nonrepeating * "#" * repeating
        period = length(digits) - cycle_start + 1
    elseif remn == 0
        terminating = join(digits)
        terminating = compact ? _format_repeated_digits(terminating) : terminating
        result *= terminating * "#0"
        period = 0
    else
        partial = join(digits)
        partial = compact ? _format_repeated_digits(partial) : partial
        result *= partial * "..."
        period = -1
    end

    (base_string=result, decimal=result, period=period, limit_hit=limit_hit)
end

function period_modulo(x::Rational, system::BaseSystem; limit::Integer=1_000_000)::Int
    r = rat(x)
    den = BigInt(denominator(r))
    den == 1 && return 0
    base_value = BigInt(system.base)
    common = gcd(den, base_value)
    while common > 1
        den ÷= common
        common = gcd(den, base_value)
    end
    den == 1 && return 0

    k = 1
    power = base_value % den
    while power != 1 && k <= limit
        power = (power * base_value) % den
        k += 1
    end
    k > limit && throw(ArgumentError("period calculation exceeded limit"))
    k
end

function _scientific_digits(r::Rational{BigInt}, precision::Integer)
    n = abs(numerator(r))
    d = denominator(r)
    digits = Char[]
    exponent = 0
    remn = big(0)

    if n >= d
        whole = string(n ÷ d)
        exponent = length(whole) - 1
        for c in whole
            push!(digits, c)
        end
        remn = n % d
    else
        remn = n
        leading_zeros = 0
        while remn * 10 < d
            remn *= 10
            leading_zeros += 1
        end
        exponent = -(leading_zeros + 1)
    end

    while length(digits) < precision && remn != 0
        remn *= 10
        push!(digits, Char(Int('0') + Int(remn ÷ d)))
        remn %= d
    end

    (digits=digits, exponent=exponent, remainder=remn)
end

function _period_digits_for_scientific(r::Rational{BigInt}; compact::Bool=true)
    rep = repeating_decimal(abs(r); compact=false)
    hash_index = findfirst('#', rep)
    isnothing(hash_index) && return ""
    period = rep[nextind(rep, hash_index):end]
    period == "0" ? "" : (compact ? _format_repeated_digits(period; threshold=7) : period)
end

function scientific_notation(x::Rational; compact::Bool=true, precision::Integer=11, show_period_info::Bool=false)::String
    r = rat(x)
    numerator(r) == 0 && return "0"
    negative = numerator(r) < 0

    sig = _scientific_digits(r, precision)
    digits = sig.digits
    rest = length(digits) > 1 ? String(digits[2:end]) : ""
    period = _period_digits_for_scientific(r; compact=compact)

    if isempty(period)
        rest = replace(rest, r"0+$" => "")
    end

    mantissa = isempty(rest) ? string(digits[1]) : string(digits[1]) * "." * rest
    !isempty(period) && (mantissa *= "#" * period)

    result = (negative ? "-" : "") * mantissa * "E" * string(sig.exponent)
    if show_period_info
        p = repeating_decimal_with_period(r; compact=compact).period
        p > 0 && (result *= " {period: $p}")
    end
    result
end
