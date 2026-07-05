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
        if count >= threshold
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

function scientific_notation(x::Rational; compact::Bool=true, precision::Integer=11, show_period_info::Bool=false)::String
    r = rat(x)
    numerator(r) == 0 && return "0"
    negative = numerator(r) < 0
    dec = repeating_decimal(abs(r); compact=compact)
    cleaned = replace(dec, "#0" => "")
    hash_index = findfirst('#', cleaned)
    plain = isnothing(hash_index) ? cleaned : cleaned[1:prevind(cleaned, hash_index)]
    plain = replace(plain, "." => "")
    first_nonzero = findfirst(c -> c != '0', plain)
    if isnothing(first_nonzero)
        return negative ? "-0" : "0"
    end

    original = replace(isnothing(hash_index) ? cleaned : cleaned[1:prevind(cleaned, hash_index)], "#" => "")
    decimal_point = findfirst('.', original)
    if isnothing(decimal_point)
        exponent = length(original) - first_nonzero
    elseif first_nonzero < decimal_point
        exponent = decimal_point - first_nonzero - 1
    else
        exponent = -(first_nonzero - decimal_point)
    end

    digits = plain[first_nonzero:end]
    mantissa = length(digits) == 1 ? string(digits[1]) : string(digits[1]) * "." * String(digits[2:min(end, precision)])
    if !isnothing(hash_index)
        period = cleaned[nextind(cleaned, hash_index):end]
        if !isempty(period)
            mantissa *= "#" * period[1:min(end, max(1, precision))]
        end
    end
    result = (negative ? "-" : "") * mantissa * "E" * string(exponent)
    if show_period_info
        p = repeating_decimal_with_period(r; compact=compact).period
        p > 0 && (result *= " {period: $p}")
    end
    result
end
