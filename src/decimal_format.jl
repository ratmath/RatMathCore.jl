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

function scientific_notation(x::Rational; compact::Bool=true, precision::Integer=11, show_period_info::Bool=false)::String
    r = rat(x)
    numerator(r) == 0 && return "0"
    negative = numerator(r) < 0
    rep = repeating_decimal(abs(r); compact=false)
    hash_index = findfirst('#', rep)
    body = isnothing(hash_index) ? rep : rep[1:prevind(rep, hash_index)]
    period = isnothing(hash_index) ? "" : rep[nextind(rep, hash_index):end]
    is_repeating = !isempty(period) && period != "0"

    dot_index = findfirst('.', body)
    whole = isnothing(dot_index) ? body : body[1:prevind(body, dot_index)]
    initial = isnothing(dot_index) ? "" : body[nextind(body, dot_index):end]

    finite_digits = whole * initial
    decimal_position = length(whole)
    first_finite = findfirst(c -> c != '0', finite_digits)

    mantissa = ""
    exponent = 0

    if !isnothing(first_finite)
        exponent = decimal_position - first_finite
        rest = finite_digits[nextind(finite_digits, first_finite):end]
        if is_repeating
            formatted_period = compact ? _format_repeated_digits(period; threshold=7) : period
            mantissa = isempty(rest) ? string(finite_digits[first_finite]) * ".#" * formatted_period :
                       string(finite_digits[first_finite]) * "." * rest * "#" * formatted_period
        else
            rest = replace(rest, r"0+$" => "")
            mantissa = isempty(rest) ? string(finite_digits[first_finite]) : string(finite_digits[first_finite]) * "." * rest
        end
    else
        is_repeating || return negative ? "-0" : "0"
        first_period = findfirst(c -> c != '0', period)
        isnothing(first_period) && return negative ? "-0" : "0"
        exponent = -(length(initial) + first_period)
        first_digit = period[first_period]
        period_tail = period[nextind(period, first_period):end]
        if isempty(period_tail)
            period_tail = string(first_digit)
        else
            period_tail = period_tail[1:min(end, max(1, precision - 3))]
        end
        formatted_period = compact ? _format_repeated_digits(period_tail; threshold=7) : period_tail
        mantissa = string(first_digit) * ".#" * formatted_period
    end

    result = (negative ? "-" : "") * mantissa * "E" * string(exponent)
    if show_period_info && is_repeating
        info = String[]
        initial_zeros = something(findfirst(c -> c != '0', initial), length(initial) + 1) - 1
        period_zeros = something(findfirst(c -> c != '0', period), length(period) + 1) - 1
        initial_zeros > 0 && push!(info, "initial: $initial_zeros zeros")
        period_zeros > 0 && push!(info, "period starts: +$period_zeros zeros")
        p = repeating_decimal_with_period(r; compact=compact).period
        p > 0 && push!(info, "period: $p")
        !isempty(info) && (result *= " {" * join(info, ", ") * "}")
    end
    result
end
