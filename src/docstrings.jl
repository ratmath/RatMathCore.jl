@doc raw"""
    rat(x)
    rat(n, d)
    rat(s::AbstractString)

Construct an exact `Rational{BigInt}`.

`rat` is the RatMath-friendly constructor for Julia's built-in rational type. It accepts integers,
integer numerator/denominator pairs, existing rationals, and RatMath-style strings.

Supported string forms include integers, fractions, terminating decimals, and mixed numbers using
`whole..numerator/denominator`.

# Examples

```julia
julia> rat("5..2/3")
17//3

julia> rat("-0.125")
-1//8
```
""" rat

@doc raw"""
    mixed(whole, numerator, denominator)

Construct an exact rational from RatMath mixed-number parts.

# Examples

```julia
julia> mixed(5, 2, 3)
17//3

julia> mixed(-2, 1, 4)
-9//4
```
""" mixed

@doc raw"""
    exact_div(a, b)

Divide two integers exactly. Returns a `BigInt` when the division is integral and a
`Rational{BigInt}` otherwise.

# Examples

```julia
julia> exact_div(6, 3)
2

julia> exact_div(5, 2)
5//2
```
""" exact_div

@doc raw"""
    reciprocal(x)

Return the exact reciprocal of a rational or rational interval.

# Examples

```julia
julia> reciprocal(2//3)
3//2

julia> reciprocal(RationalInterval(2, 4))
1/4:1/2
```
""" reciprocal

@doc raw"""
    pow_exact(x, n)

Raise an integer, rational, or `Fraction` to an integer power using RatMath-compatible edge cases.

Unlike Julia Base, RatMath compatibility treats ``0^0`` as an error.

# Examples

```julia
julia> pow_exact(2//3, -2)
9//4
```
""" pow_exact

@doc raw"""
    e_notation(x, exponent)

Apply scientific `E` notation exactly by multiplying `x` by ``10^{exponent}``.

# Examples

```julia
julia> e_notation(45, -1)
9//2

julia> e_notation(Fraction(5, 4), 2)
500/4
```
""" e_notation

@doc raw"""
    bit_length(x)

Return the number of bits needed to represent an integer's magnitude, or the maximum bit length
of a rational's numerator and denominator.

# Examples

```julia
julia> bit_length(-5)
3
```
""" bit_length

@doc raw"""
    double_factorial(n)

Compute ``n!!`` exactly for non-negative integers.

# Examples

```julia
julia> double_factorial(6)
48
```
""" double_factorial

@doc raw"""
    to_mixed_string(x)

Render a rational or rational interval using RatMath mixed-number notation.

# Examples

```julia
julia> to_mixed_string(-7//3)
"-2..1/3"
```
""" to_mixed_string

@doc raw"""
    to_decimal(x; maxdigits=20)
    to_decimal(system::BaseSystem, s)

For rationals, render a terminating decimal exactly or a truncated decimal using `maxdigits`.
For base systems, parse a digit string into a decimal `BigInt`.

# Examples

```julia
julia> to_decimal(1//4)
"0.25"

julia> to_decimal(BaseSystem("01", "Binary"), "1010")
10
```
""" to_decimal

@doc raw"""
    RationalInterval(a, b)

An exact closed interval over `Rational{BigInt}` endpoints.

The original endpoint order is kept as `start` and `stop`; ordered mathematical bounds are stored
as `low` and `high`.

# Examples

```julia
julia> RationalInterval(2, 1)
2:1

julia> RationalInterval(2, 1).low
1//1
```
""" RationalInterval

@doc raw"""
    point_interval(x)

Create the point interval `[x, x]`.

# Examples

```julia
julia> point_interval(3//4)
3/4:3/4
```
""" point_interval

@doc raw"""
    parse_interval(s)

Parse a string of the form `"a:b"` into a `RationalInterval`.

# Examples

```julia
julia> parse_interval("1/3:2/3")
1/3:2/3
```
""" parse_interval

@doc raw"""
    contains_zero(interval)

Return `true` when zero is inside an interval's closed bounds.
""" contains_zero

@doc raw"""
    overlaps(a, b)

Return `true` when two rational intervals have a non-empty intersection.
""" overlaps

@doc raw"""
    intersection(a, b)

Return the intersection of two rational intervals, or `nothing` when they are disjoint.
""" intersection

@doc raw"""
    union(a, b)

Return the interval union of overlapping or touching rational intervals, or `nothing` when they
are disjoint.

This method extends `Base.union` for `RationalInterval`.
""" union

@doc raw"""
    midpoint(interval)

Return the arithmetic midpoint of a rational interval.
""" midpoint

@doc raw"""
    mediant(a, b)
    mediant(interval)

For fractions, return ``(a.num + b.num) / (a.den + b.den)`` without reducing. For intervals,
return the mediant of the rational endpoints.
""" mediant

@doc raw"""
    pow_interval(interval, n)

Pointwise interval exponentiation. This encloses ``x^n`` for every ``x`` in the interval.

# Examples

```julia
julia> pow_interval(RationalInterval(-2, 3), 2)
0:9
```
""" pow_interval

@doc raw"""
    mpow_interval(interval, n)

Multiplicative interval exponentiation by repeated interval multiplication. This preserves interval
dependency behavior and may be wider than `pow_interval`.

# Examples

```julia
julia> mpow_interval(RationalInterval(-1, 1), 2)
-1:1
```
""" mpow_interval

@doc raw"""
    shortest_decimal(interval; base=10)

Find a rational inside an interval whose denominator is the smallest explored power of `base`.
""" shortest_decimal

@doc raw"""
    random_rational(interval; max_denominator=1000, rng=nothing)

Choose a reduced rational inside an interval from denominators up to `max_denominator`.

Pass an RNG as `rng` for deterministic tests.
""" random_rational

@doc raw"""
    compacted_decimal_interval(interval)

Render an interval by factoring out the common decimal prefix of the original endpoints when the
remaining suffixes are numeric.

# Examples

```julia
julia> compacted_decimal_interval(RationalInterval(12356//10000, 12367//10000))
"1.23[56,67]"
```
""" compacted_decimal_interval

@doc raw"""
    relative_mid_decimal_interval(interval)

Render an interval as midpoint plus/minus decimal offsets.
""" relative_mid_decimal_interval

@doc raw"""
    relative_decimal_interval(interval)

Render an interval relative to a short exact decimal inside the interval.
""" relative_decimal_interval

@doc raw"""
    Fraction(n, d=1; allow_infinite=false)
    Fraction(s; allow_infinite=false)

An unreduced numerator/denominator pair.

Unlike Julia's `Rational`, `Fraction(2, 4)` and `Fraction(1, 2)` are distinct values. Limited
infinite sentinels `1/0` and `-1/0` are allowed only when `allow_infinite=true`.

# Examples

```julia
julia> Fraction(2, 4) == Fraction(1, 2)
false

julia> rational(Fraction(2, 4))
1//2
```
""" Fraction

@doc raw"""
    reduce_fraction(f)

Return a reduced `Fraction`, preserving `Fraction` representation rather than converting to
Julia's `Rational`.
""" reduce_fraction

@doc raw"""
    rational(f::Fraction)

Convert a finite unreduced `Fraction` to Julia's reduced `Rational{BigInt}`.
""" rational

@doc raw"""
    scale(f, factor)

Multiply both the numerator and denominator of a `Fraction` by `factor`.
""" scale

@doc raw"""
    farey_parents(f)

Return the Farey parent pair whose mediant is `f`.
""" farey_parents

@doc raw"""
    mediant_partner(endpoint, mediant)

Given one endpoint and a mediant, compute the other endpoint using RatMath's simple partner rule.
""" mediant_partner

@doc raw"""
    is_mediant_triple(left, mediant, right)

Return `true` when `mediant` is the exact unreduced mediant of `left` and `right`.
""" is_mediant_triple

@doc raw"""
    is_farey_triple(left, mediant, right)

Return `true` when three fractions form a mediant triple and the endpoints are Farey adjacent.
""" is_farey_triple

@doc raw"""
    stern_brocot_path(f)

Return the path from the root `0/1` to a finite fraction in the RatMath Stern-Brocot tree.
""" stern_brocot_path

@doc raw"""
    stern_brocot_string(f)

Return the Stern-Brocot path as a compact string such as `"RLRL"`.

`stern_brocot_path` returns character steps for programmatic use; this helper is intended for
compact display and documentation.

# Examples

```julia
julia> stern_brocot_string(Fraction(3, 5))
"RLRL"
```
""" stern_brocot_string

@doc raw"""
    from_stern_brocot_path(path)

Construct a `Fraction` from a Stern-Brocot path containing `L` and `R` steps.
""" from_stern_brocot_path

@doc raw"""
    stern_brocot_parent(f)
    stern_brocot_children(f)
    stern_brocot_depth(f)
    stern_brocot_ancestors(f)

Navigate the Stern-Brocot tree for finite `Fraction` values.
""" stern_brocot_parent, stern_brocot_children, stern_brocot_depth, stern_brocot_ancestors

@doc raw"""
    FractionInterval(a, b)

An ordered closed interval over unreduced `Fraction` endpoints.
""" FractionInterval

@doc raw"""
    mediant_split(interval)

Split a `FractionInterval` into two intervals at the endpoint mediant.
""" mediant_split

@doc raw"""
    partition_with_mediants(interval, depth=1)

Recursively split a `FractionInterval` by mediants.
""" partition_with_mediants

@doc raw"""
    partition_with(interval, fn)

Partition a `FractionInterval` using a callback that returns internal `Fraction` points.
""" partition_with

@doc raw"""
    rational_interval(interval)
    fraction_interval(interval)

Convert between `FractionInterval` and `RationalInterval`.
""" rational_interval, fraction_interval

@doc raw"""
    BaseSystem(characters, name="")

A custom positional digit alphabet.

Digits are zero-indexed by position in `characters`. Reserved parser symbols such as `+`, `/`,
`:`, `.`, `#`, and `~` are rejected.

# Examples

```julia
julia> binary = BaseSystem("01", "Binary");

julia> to_decimal(binary, "1010")
10
```
""" BaseSystem

@doc raw"""
    base_system(base; name=nothing)

Construct a standard alphanumeric base system for bases 2 through 62.
""" base_system

@doc raw"""
    create_base_pattern(pattern, size; name=nothing)

Create a base system from a named pattern: `:alphanumeric`, `:digits_only`,
`:letters_only`, or `:uppercase_only`.
""" create_base_pattern

@doc raw"""
    from_decimal(system, value)

Render an integer in a `BaseSystem`.
""" from_decimal

@doc raw"""
    to_base(value, system; repeating=false)
    to_base(value, base; repeating=false)

Render an integer or rational using a base system. Rationals render as numerator/denominator in
the requested base unless `repeating=true`, in which case RatMath repeating expansion notation is
used.

# Examples

```julia
julia> to_base(10, BaseSystem("01", "Binary"))
"1010"

julia> to_base(10//3, BaseSystem("01", "Binary"))
"1010/11"
```
""" to_base

@doc raw"""
    valid_digit_string(system, s)

Return `true` when `s` contains only digits from `system`.
""" valid_digit_string

@doc raw"""
    with_case_sensitivity(system, case_sensitive)

Return `system` unchanged when `case_sensitive=true`; otherwise return a lowercased digit alphabet.
""" with_case_sensitivity

@doc raw"""
    register_prefix!(prefix, system)
    unregister_prefix!(prefix)
    system_for_prefix(prefix)
    prefix_for_system(system)

Manage the package-level base-prefix registry.
""" register_prefix!, unregister_prefix!, system_for_prefix, prefix_for_system

@doc raw"""
    get_char(system, value)

Return the digit character for a zero-based digit value in `system`.
""" get_char

@doc raw"""
    repeating_decimal(x; compact=true)
    repeating_decimal_with_period(x; compact=true)

Render an exact rational in RatMath repeating-decimal notation. `#0` marks a terminating decimal;
`#digits` marks the repeating period.

# Examples

```julia
julia> repeating_decimal(1//7)
"0.#142857"

julia> repeating_decimal_with_period(1//7).period
6
```
""" repeating_decimal, repeating_decimal_with_period

@doc raw"""
    repeating_base(x, system; compact=true, limit=1000)
    repeating_base_with_period(x, system; compact=true, limit=1000)

Render a rational expansion in a custom base system.
""" repeating_base, repeating_base_with_period

@doc raw"""
    period_modulo(x, system; limit=1_000_000)

Compute the repeating period length of a rational expansion in a base system using modular
arithmetic after removing terminating factors.
""" period_modulo

@doc raw"""
    scientific_notation(x; compact=true, precision=11, show_period_info=false)

Render a rational in a compact scientific-notation string using RatMath repeating markers when
needed.
""" scientific_notation

@doc raw"""
    continued_fraction(x; max_terms=1000)
    from_continued_fraction(terms)

Convert between exact rationals and continued-fraction coefficient vectors.
""" continued_fraction, from_continued_fraction

@doc raw"""
    continued_fraction_string(x)
    from_continued_fraction_string(s)

Convert between rationals and RatMath continued-fraction string notation, such as `"3.~7~16"`.
""" continued_fraction_string, from_continued_fraction_string

@doc raw"""
    convergents(x; max_count=1000)
    convergents_from_cf(input; max_count=1000)
    get_convergent(x, n)

Compute continued-fraction convergents.
""" convergents, convergents_from_cf, get_convergent

@doc raw"""
    approximation_error(x, target)
    best_approximation(x, max_denominator)

Helpers for rational approximation using continued fractions.
""" approximation_error, best_approximation
